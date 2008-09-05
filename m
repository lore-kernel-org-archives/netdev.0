From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 15:06:42 +0200
Message-ID: <7e0dd21a0809050606t42e5ee06nc8259d146c77868e@mail.gmail.com>
References: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
	 <7e63f56c0809050328j63b901dbgffb0fa5836229d70@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?Q?Ulisses_Alonso_Camar=F3?=" <uaca@alumni.uv.es>
To: "Robert Iakobashvili" <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:44202 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbYIENGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 09:06:42 -0400
Received: by rv-out-0506.google.com with SMTP id k40so445320rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 06:06:42 -0700 (PDT)
In-Reply-To: <7e63f56c0809050328j63b901dbgffb0fa5836229d70@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Robert,

The architecture of PF_RING seems to be really similar to packet mmap
IO to optimize capture process.
Is it planned to replace it?

I'll try it to get performance.

Best regards,
Johann



On Fri, Sep 5, 2008 at 12:28 PM, Robert Iakobashvili
<coroberti@gmail.com> wrote:
> Hi Johann,
>
> On Tue, Sep 2, 2008 at 9:27 PM, Johann Baudy <johaahn@gmail.com> wrote:
>> I've made lot of tests, playing with jumbo frames, raw sockets, ...
>> I've never exceeded ~25Mbytes/s. So I've decided to analyze deeply the
>> packet socket transmission process.
>>
>> The main blocking point was the memcpy_fromiovec() function that is
>> located in the packet_sendmsg() of af_packet.c.
>> It was consuming all my CPU resources to copy data from user space to
>> socket buffer.
>> Then I've started to work on a hack that makes this transfer possible
>> without any memcpys.
>>
>> Mainly, the hack is the implementation of two "features":
>>
>>    *  Sending packet through a circular buffer between user and
>> kernel space that minimizes the number of system calls. (Feature
>> actually implemented for capture process, libpcap ..).
>
> Something like this has been done in PF_RING socket,
> which is a part of ntop project infra.
>
> Take care.
>
> Truly,
> Robert Iakobashvili
> ......................................................................
> www.ghotit.com
> Assistive technology that understands you
> ......................................................................
>



-- 
Johann Baudy
johaahn@gmail.com
