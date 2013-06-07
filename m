From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Fri, 07 Jun 2013 10:15:26 -0700
Message-ID: <51B2152E.5010105@gmail.com>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>  <87fvx4mvtl.fsf@nemi.mork.no>  <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>  <51B1F1FF.5010004@intel.com> <1370618634.1903.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, Narendra_K@Dell.com,
	bjorn@mork.no, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:39329 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab3FGRPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 13:15:39 -0400
Received: by mail-oa0-f46.google.com with SMTP id h2so3572765oag.19
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 10:15:39 -0700 (PDT)
In-Reply-To: <1370618634.1903.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2013 08:23 AM, Ben Hutchings wrote:
> On Fri, 2013-06-07 at 07:45 -0700, John Fastabend wrote:
>> On 5/31/2013 5:17 AM, Narendra_K@Dell.com wrote:
>>> On Thu, May 30, 2013 at 07:08:46PM +0530, Bj=C3=B8rn Mork wrote:
>>>>
>>>> <Narendra_K@Dell.com> writes:
>>>>
>>>>> From: Narendra K <narendra_k@dell.com>
>>>>>
>>>>> 'dev_id' sysfs attribute is initialized to zero by default.
>>>>> It is also zero based. This creates ambiguity in differentiating
>>>>> whether the driver set it to zero or it is the default value.
>>>>> Initialize 'dev_id' to -1 to make the scenario unambiguous.
>>>>
>>>> I understand your concern, but I don't think you can do this.  It
>>>> changes the userspace API, and has some very visible side effects.
>>>>
>>>> Please take a look at net/ipv6/addrconf.c
>>>
>>> Ok, thank you for pointing it. I missed it while looking for its
>>> possible use scenarios.
>>
>> Although I'm not sure how that check works with devices that are
>> setting dev_id and also provide their own mac addresses. From
>> inspection it looks like these devices end up with a local interface
>> identifier unnecessarily.
>>
>> Maybe Ben knows one of the drivers is the siena solorflare controlle=
r
>> apparently for the SFC9000 family? The other two 'grep' finds are
>> an mlx and chelsio device.
>>
>> Interestingly I didn't find any devices setting dev_id that also
>> didn't program unique mac addresses. Perhaps I'm missing something?
>
> I set this for Siena so that userland can tell which PF and port is
> which even if the PCIe topology is hidden by virtualisation.  In
> practice we haven't made use of that (and since virtualisation may al=
so
> hide the VPD and serial number capabilities, it probably doesn't help
> much).
>
> Ben.
>

I guess then to make dev_id work like Narendra wants you would need
something in the management stack to come through and assign unique
dev_id values to functions (net_devices) that share a MAC. Or have some
unique 'unsigned short' value in the driver that it could be set to.
I guess I miss why initializing it to -1 helps.

Still best I can tell your ipv6 identifiers are not going to have
the 'u' bit inverted creating a somewhat strange side effect from
setting the dev_id.

=2EJohn



--=20
John Fastabend         Intel Corporation
