From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] net: ovs: flow: fix potential illegal memory access
 in __parse_flow_nlattrs
Date: Sat, 7 Sep 2013 22:35:33 -0700
Message-ID: <CAEP_g=_Bgt8OsORTyYRt=tbssfbd-0Jh2HhnjPdj1aVP8Zd1BA@mail.gmail.com>
References: <1378539694-3635-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:53961 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751442Ab3IHFfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 01:35:55 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so4106339lbi.29
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 22:35:53 -0700 (PDT)
In-Reply-To: <1378539694-3635-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 7, 2013 at 12:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> In function __parse_flow_nlattrs(), we check for condition
> (type > OVS_KEY_ATTR_MAX) and if true, print an error, but we do
> not return from this function as in other checks. It seems this
> has been forgotten, as otherwise, we could access beyond the
> memory of ovs_key_lens, which is of ovs_key_lens[OVS_KEY_ATTR_MAX + 1].
> Hence, a maliciously prepared nla_type from user space could access
> beyond this upper limit.
>
> Introduced by 03f0d916a ("openvswitch: Mega flow implementation").
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Andy Zhou <azhou@nicira.com>

Yeah, looks like a mistake to me.

Acked-by: Jesse Gross <jesse@nicira.com>
