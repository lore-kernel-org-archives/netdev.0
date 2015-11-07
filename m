From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Sat, 7 Nov 2015 14:11:17 +0100
Message-ID: <563DF875.7090104@openwrt.org>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com>
 <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com>
 <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com>
 <CAFBinCDZDYJGjimsAD=+HFokc9ga0cLBD1KSAieagzWQNH+s=w@mail.gmail.com>
 <CA+FuTSfw+-6Xb_0xchM5E6vCMSsyiSvSYF3MbuE25pEt07RRbw@mail.gmail.com>
 <CAFBinCBYv44ttGNyny11gEwNMJDwYzO=YYJC5scwOE-PN2nn4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, johann.baudy@gnu-log.net,
	paulus@samba.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:36447 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbbKGNLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2015 08:11:32 -0500
In-Reply-To: <CAFBinCBYv44ttGNyny11gEwNMJDwYzO=YYJC5scwOE-PN2nn4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-07-31 00:15, Martin Blumenstingl wrote:
> On Wed, Jul 29, 2015 at 8:05 AM, Willem de Bruijn <willemb@google.com> wrote:
>> Martin, to return to your initial statement that PPPoE PADI packets can
>> have a zero payload: the PPPoE RFC states that PADI packets "MUST
>> contain exactly one TAG of TAG_TYPE Service-Name, indicating the
>> service the Host is requesting, and any number of other TAG types."
>> (RFC 2516, 5.1). Is the observed behavior (no payload) perhaps
>> incorrect?
> As far as I can see you are right, but the real world seems to be different.
> My ISP for example lists the PPPoE connection settings, but they are
> nowhere mentioning the "service name".
> 
> I have also re-read pppd's source code again and that seems to confirm
> what you are reading in the RFC: Leaving the service name away makes
> seems to violate the RFC, but pppd still accepts those configurations.
> 
>> Even if it is, if this is breaking established userspace expectations,
>> we should look into it. Ethernet specifies a minimum payload size of
>> 46 on the wire, but perhaps that is handled with padding, so that
>> 0 length should be valid within the stack. Also, there may be other
>> valid uses of 0 length payload on top of link layers that are not Ethernet.
> Good catch. I would also like to note that the documentation for
> "hard_header_len" describes it as "Hardware header length". When the
> purpose of this field we should check whether the documentation should
> be updated to "Minimum hardware header length" -> that would mean the
> condition has to be a "len < hard_header_len" instead of a "len <=
> hard_header_len" (as it is now).
> 
> PS: I have also added the pppd maintainer (Paul Mackerras) to this
> thread because I think he should know about this issue (and he can
> probably provide more details if required).
> As a quick summary for him: linux  >= 3.19 rejects PADI packets when
> no service name is configured.
Any news on this? Users are complaining about this regression:
https://dev.openwrt.org/ticket/20707

- Felix
