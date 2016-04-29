From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 4/5] bnxt: Add support for segmentation of tunnels
 with outer checksums
Date: Fri, 29 Apr 2016 14:17:06 -0700
Message-ID: <CAKgT0UeOPX22XipaSUsCgZ9oPsw1Q6KWGoEA+rpjANp6RQ+gnA@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
	<20160419190615.11723.53966.stgit@ahduyck-xeon-server>
	<CACKFLi=2mHfOS1Rz5RbSdyhepdjBqM+dj7Nh=CzARcYSwUTcSw@mail.gmail.com>
	<CAKgT0UffVkQWWqgwYZy-AXEq=kofKiRx2D9pnu5nBQD+uSLS+g@mail.gmail.com>
	<CACKFLi=0ug=E++9prBjC7NsD67+DtLKXXwFtF-E0+trVNtMgbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36455 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbcD2VRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:17:07 -0400
Received: by mail-io0-f170.google.com with SMTP id u185so139074214iod.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 14:17:07 -0700 (PDT)
In-Reply-To: <CACKFLi=0ug=E++9prBjC7NsD67+DtLKXXwFtF-E0+trVNtMgbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 9:32 PM, Michael Chan <michael.chan@broadcom.com> wrote:
> On Wed, Apr 27, 2016 at 8:21 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Tue, Apr 26, 2016 at 10:55 PM, Michael Chan
>> <michael.chan@broadcom.com> wrote:
>>> On Tue, Apr 19, 2016 at 12:06 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>> This patch assumes that the bnxt hardware will ignore existing IPv4/v6
>>>> header fields for length and checksum as well as the length and checksum
>>>> fields for outer UDP and GRE headers.
>>>>
>>>> I have no means of testing this as I do not have any bnx2x hardware but
>>>> thought I would submit it as an RFC to see if anyone out there wants to
>>>> test this and see if this does in fact enable this functionality allowing
>>>> us to to segment tunneled frames that have an outer checksum.
>>>>
>>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>>
>>> Hi Alex, I just did a very quick test of this patch on our bnxt
>>> hardware and it seemed to work.
>>>
>>> I created a vxlan endpoint with udpcsum enabled and I saw TSO packets
>>> getting through.  I've verified that our hardware can be programmed to
>>> either ignore outer UDP checksum or to calculate it.  Current default
>>> is to ignore ipv4 UDP checksum and calculate ipv6 UDP checksum.
>>> Thanks.
>>
>> Are you saying you can natively support UDP tunnel with outer checksum
>> offload then?
>
> Yes.  Calculate or ignore the outer UDP checksum.

I was just thinking about this.  When you say you compute the IPv6
checksum how is it you are specifying to the hardware that you want to
do that?  Is it something you can configure per packet or is it
something that is configured for the VXLAN flow?

I just want to make sure you aren't adding checksums to IPv6 tunnels
that specify that they don't want a checksum, or stripping them from
v4 tunnels that do want a checksum.

Thanks.

- Alex
