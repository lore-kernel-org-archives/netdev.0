From: Michael Kerrisk <mtk-manpages@gmx.net>
Subject: Re: Problem with semantics?
Date: Mon, 27 Aug 2007 17:46:09 +0200
Message-ID: <46D2F1C1.2050606@gmx.net>
References: <OFF8FEF8BA.07073375-ONC2257336.005DB73A-C2257336.005E19ED@il.ibm.com> <p737inzne6i.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Shay Goikhman <GOIKHMAN@il.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37676 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754663AbXH0PsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 11:48:04 -0400
In-Reply-To: <p737inzne6i.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andi,

Andi Kleen wrote:
> Shay Goikhman <GOIKHMAN@il.ibm.com> writes:
> 
>> Dear Linux maintainers,
>>
>>  I'm doing :
>>
>>       setsockopt(s,  SO_RCVTIMEO, t1 );                  // set time-out
>> t1 on socket while block receiving on it
>>       select(,,, &fd_set_including(s), .., &errs, t2);      // block till
>> receive or time-out  t 2 jointly on a set of sockets
>>
>> Apparently, I could no find reference on the coupled behavior of the two
>> above statements in Linux documentation.
>> As I understand the blocking semantics, I would expect  that  if t1<t2 ,
>> select should return after t1 with the descriptor 's' in 'errs' if 's' does
>> not become readable in the t1 interval.
>>
>> It is not so in life -- select ignores t1 altogether.
>>
>> Do you have some enlightening knowledge on the matter?
> 
> RCVTIMEO only applies to recvmsg et.al., similar to SNDTIMEO only
> apply to sendmsg etc. But select/poll only report events, they
> do not actually send or receive by themselves.
> 
> Michael, perhaps you can clarify that in the manpages

I added the following to sockets.7:

              Timeouts have
              effect   for  socket  I/O  calls  (read(2),  recv(2),
              recvfrom(2),    recvmsg(2),    write(2),     send(2),
              sendto(2),  sendmsg(2));  timeouts have no effect for
              select(2), poll(2), epoll_wait(2), etc.

The change will be in man-pages-2.65.

Thanks for your note.

Cheers,

Michael

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.
