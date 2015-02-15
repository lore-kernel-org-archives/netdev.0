From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sun, 15 Feb 2015 16:08:42 +0100
Message-ID: <54E0B67A.1030000@6wind.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com> <1423901633-53789-4-git-send-email-joestringer@nicira.com> <20150214195607.GA30752@casper.infradead.org> <CANr6G5x19zc8qK0gtPBFzMD02xMxieFqGpv9-nkKyiZ1MzSUwA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:61000 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbbBOPIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 10:08:45 -0500
Received: by mail-qa0-f47.google.com with SMTP id v10so19030141qac.6
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 07:08:45 -0800 (PST)
In-Reply-To: <CANr6G5x19zc8qK0gtPBFzMD02xMxieFqGpv9-nkKyiZ1MzSUwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/02/2015 05:47, Joe Stringer a =C3=A9crit :
> On 14 February 2015 at 11:56, Thomas Graf <tgraf@suug.ch> wrote:
>> On 02/14/15 at 12:13am, Joe Stringer wrote:
>>
>> [..]
>>
>>> +static bool skb_has_valid_nfct(const struct net *net, u16 zone,
>>> +                            const struct sk_buff *skb)
>>> +{
>>> +     enum ip_conntrack_info ctinfo;
>>> +     struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
>>> +
>>> +     if (!ct)
>>> +             return false;
>>> +     if (!net_eq(net, ct->ct_net))
>>> +             return false;
>>
>> I'm surprised that this is needed. Shouldn't we call skb_scrub_packe=
t()
>> between namespaces and invalidate the ct associated with the skb.
>
> Right, it was more of a general sanity check which is likely unneeded=
=2E
> I'm not aware of any particular case that this handles.
I agree with Thomas. If we fall into this case, it's probably a real bu=
g ;-)
