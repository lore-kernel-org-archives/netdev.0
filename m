From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Fri, 05 Jun 2015 07:16:08 -0700
Message-ID: <5571AF28.8000009@cumulusnetworks.com>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com> <20150605091441.GA11896@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33087 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030184AbbFEOQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 10:16:12 -0400
Received: by iebgx4 with SMTP id gx4so58595418ieb.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 07:16:11 -0700 (PDT)
In-Reply-To: <20150605091441.GA11896@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/15, 2:14 AM, Thomas Graf wrote:
> On 06/03/15 at 07:21am, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is still WIP and incomplete.
>> Posting it here because of the other discussions
>> happening around mpls ler in the context of Roberts
>> code and I happened to mention this implementation.
>>
>> This was in response to earlier email thread with Eric on
>> net-next of possibly using xfrm style stacked destination
>> approach.
>>
>> I introduce a new set of tunnel ops for light weight
>> tunnels (lwt), but this could be merged with the
>> other ip_tunnels code if possible.
>>
>> I had this code for 3.2 kernel initially, and
>> as I was pulling out code, I realize i had to separate
>> out some other mpls code that i have been working on
>> and quite likely this will not even compile. Sorry abt
>> that.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Thanks for posting these patches Roopa!
>
> I see that some of the edges are still a bit rough. In particular
> the lack of sanity checking around type before indexing the array
> with it ;-)
Oh..., sorry you had to see that :)
(In my defense, ...i did successfully get some packets into the mpls 
tunnel with this though! :) )
> No question that this would make a great optimization
> on top of existing IP tunnels though! I think this is where Eric
> was heading to and given this implementation, I'm perfectly fine
> with it as it does not *require* to precompute the headers for all
> encap types.
>
> This can be made compatible with the patches I have posted as well.
> A simple flag in what you call rtencap could indicate whether to
> perform the encap in the dst->output or merely attach the metadata
> and forward it to RTA_OIF for postponed encapsulation.
>
> That way, if desirable by the user, the net_device can be omitted
> which would suit Eric's architecture while we still also support
> the traditional net_device model which provides stats and a shared
> set of encapsulation parameters. It will also allow for bridges to
> perform the encapsulation decision if needed and we can still get
> rid of the OVS encapsulation special handling.
yeah, that's a great idea.
>
> As I mentioned to Robert, the new RTA_ENCAP should be a list of
> Netlink attributes from the beginning to make it extendible without
> ever breaking user ABI.
agreed.
>
> The most overlap seems to be with Robert's series. The direction
> seems to be very similar. How do you want to proceed? Work on a
> series together? I'm happy to rebase my series on top of both you
> and Robert's work and make use of a new generic per nexthop
> encapsulation API. Let me know how you guys want to proceed.
Robert, pls let me know if you have a preference on how you want to 
proceed. One
option is for me to use your git tree as a way to get my patches in.
But, If we agree that we don't want to introduce a tunnel netdevice for 
mpls yet (which is our vote as well),
then its probably better for me to rebase my changes on top of your 
series and
re-submit (with proper attribution ofcourse).
(Happy to take erics feedback as well here).

Right now I am working on refining my patches and covering ipv6.
I would be happy to make RTA_ENCAP nested...unless you would prefer to 
take that over.
I have also been trying to see If i can reuse any infra from the 
existing ip_tunnel world.

Thanks for the feedback Thomas!.
