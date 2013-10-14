From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [ovs-dev] [PATCH v2 net-next] openvswitch: fix vport-netdev unregister
Date: Sun, 13 Oct 2013 20:23:03 -0700
Message-ID: <CAADnVQ+zL9SaMJL3+E+84pctNMBRoUbWwgTMnkvUGc2Sh2P=-w@mail.gmail.com>
References: <1381540347-3679-1-git-send-email-ast@plumgrid.com>
	<slrnl5m3oc.3lg.xiyou.wangcong@linux-6brj.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:65273 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817Ab3JNDXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 23:23:04 -0400
Received: by mail-qc0-f170.google.com with SMTP id n9so1724194qcw.1
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 20:23:03 -0700 (PDT)
In-Reply-To: <slrnl5m3oc.3lg.xiyou.wangcong@linux-6brj.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 2:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, 12 Oct 2013 at 01:12 GMT, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> @@ -87,7 +81,11 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
>>       if (!vport)
>>               return NOTIFY_DONE;
>>
>> -     if (event == NETDEV_UNREGISTER) {
>> +     if (event == NETDEV_UNREGISTER && dev->priv_flags & IFF_OVS_DATAPATH) {
>> +             /* upper_dev_unlink and decrement promisc immediately */
>> +             ovs_netdev_detach_dev(vport);
>> +
>> +             /* schedule vport destroy, dev_put and genl notification */
>
> ovs_netdev_get_vport() already checks IFF_OVS_DATAPATH flag before this 'if'.

:) good point. will do v3.
