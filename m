From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net] openvswitch: Fix mask generation for IPv6 labels.
Date: Wed, 19 Nov 2014 11:08:35 -0800
Message-ID: <CALnjE+pQnUGiiuWPGt7fNnBetwdn7SQReDqCHDforX7ykQQR8Q@mail.gmail.com>
References: <1416336857-61405-1-git-send-email-joestringer@nicira.com>
	<CAOftzPgYBBFTfNZunf4oGSmECzjOKF0=dnQ9EkTDFsDi+9jfNw@mail.gmail.com>
	<CALnjE+rr2tFdvD+X=BbAza_5ad4DYs6viwvZWHCebQYmpvKU3Q@mail.gmail.com>
	<201411190948.11857.joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:41980 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754559AbaKSTIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 14:08:42 -0500
Received: by mail-ie0-f174.google.com with SMTP id rl12so1122211iec.5
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 11:08:36 -0800 (PST)
In-Reply-To: <201411190948.11857.joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 9:48 AM, Joe Stringer <joestringer@nicira.com> wrote:
> On Wednesday, November 19, 2014 00:11:01 Pravin Shelar wrote:
>> On Tue, Nov 18, 2014 at 11:25 PM, Joe Stringer <joestringer@nicira.com>
> wrote:
>> > On 18 November 2014 22:09, Pravin Shelar <pshelar@nicira.com> wrote:
>> >> On Tue, Nov 18, 2014 at 10:54 AM, Joe Stringer <joestringer@nicira.com>
>> >>
>> >> wrote:
>> >> > When userspace doesn't provide a mask, OVS datapath generates a fully
>> >> > unwildcarded mask for the flow. This is done by taking a copy of the
>> >> > flow key, then iterating across its attributes, setting all values to
>> >> > 0xff. This works for most attributes, as the length of the netlink
>> >> > attribute typically matches the length of the value. However, IPv6
>> >> > labels only use the lower 20 bits of the field. This patch makes a
>> >> > special case to handle this.
>> >> >
>> >> > This fixes the following error seen when installing IPv6 flows without
>> >> > a mask:
>> >> >
>> >> > openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff,
>> >> > max=fffff)
>> >>
>> >> We should allow exact match mask here rather than generating
>> >> wildcarded mask. So that ovs can catch invalid ipv6.label.
>> >
>> > I don't quite follow, I thought this was exact-match? (The existing
>> > function sets all bits to 1)
>>
>> With 0xffffffff value we can exact match on all ipv6.lable bits.
>
> The label field is only 20 bits. The other bits in the same word of the IPv6
> header are for version (fixed) and traffic class (handled separately). We don't
> do anything with the other bits.

This is just to make sure that we do not use those field for any thing
else. Masking those extra bits can hide incorrect ipv6 key extraction.
