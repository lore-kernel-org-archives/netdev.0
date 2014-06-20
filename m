From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 78481] New: missing  NULL check of the parameter in
 function nla_parse_nested() which is called in dcbnl_ieee_set()
Date: Fri, 20 Jun 2014 08:45:10 -0700
Message-ID: <20140620084510.1555a0e7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:53731 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbaFTPpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 11:45:13 -0400
Received: by mail-pb0-f41.google.com with SMTP id ma3so3260050pbc.28
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 08:45:12 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id ek2sm14101728pbd.30.2014.06.20.08.45.12
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:45:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 20 Jun 2014 05:02:30 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 78481] New: missing  NULL check of the parameter in function nla_parse_nested() which is called in dcbnl_ieee_set()


https://bugzilla.kernel.org/show_bug.cgi?id=78481

            Bug ID: 78481
           Summary: missing  NULL check of the parameter in function
                    nla_parse_nested() which is called in dcbnl_ieee_set()
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: rucsoftsec@gmail.com
        Regression: No

In function dcbnl_ieee_set() at net/dcb/dcbnl.c:1174, the parameter in
nla_parse_nested() at line 1184 should be checked before the call to
nla_parse_nested(). but in function dcbnl_ieee_set(), the check is missed.
The related code snippets in function dcbnl_ieee_set() are as followings.
dcbnl_ieee_set @ net/dcb/dcbnl.c:1174
1174 static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
1175                           u32 pid, u32 seq, u16 flags)
1176 {
1177         const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
1178         struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
1179         int err = -EOPNOTSUPP;
1180 
1181         if (!ops)
1182                 goto err;
1183 
1184         err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX,
1185                                tb[DCB_ATTR_IEEE], dcbnl_ieee_policy);
1186         if (err)
1187                 goto err;
     ...
1221 err:
1222         dcbnl_reply(err, RTM_SETDCB, DCB_CMD_IEEE_SET, DCB_ATTR_IEEE,
1223                     pid, seq, flags);
1224         return err;
1225 }

Generally, the parameter of nla_parse_nested() shall be checked against NULL ,
like the following code snippets in function nl80211_set_cqm().
nl80211_set_cqm @ drivers/thermal/thermal_sys.c:1227
4700 static int nl80211_set_cqm(struct sk_buff *skb, struct genl_info *info)
4701 {
     ...
4706         cqm = info->attrs[NL80211_ATTR_CQM];
4707         if (!cqm) {
4708                 err = -EINVAL;
4709                 goto out;
4710         }
4711 
4712         err = nla_parse_nested(attrs, NL80211_ATTR_CQM_MAX, cqm,
4713                                nl80211_attr_cqm_policy);
4714         if (err)
4715                 goto out;
     ...
4727 out:
4728         return err;
4729 }

Thak you!

RUC_Soft_Sec, supported by China.X.Orion

-- 
You are receiving this mail because:
You are the assignee for the bug.
