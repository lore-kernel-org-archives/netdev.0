From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Hang when testing with AMD64 with Tg3
Date: Tue, 05 Oct 2004 07:58:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162B6B2.6030208@us.ibm.com>
References: <1096935071.22155.6.camel@localhost.localdomain>	 <20041005001527.GB13106@wotan.suse.de> <1096938308.22947.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1096938308.22947.3.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 2004-10-05 at 02:15 +0200, Andi Kleen wrote:
> 
>>On Mon, Oct 04, 2004 at 05:11:11PM -0700, Stephen Hemminger wrote:
>>
>>>Doing simple iperf test on new opteron with tg3 against existing Xeon
>>>system.  I am seeing something wierd, the connection hangs right away.
>>>Is this a TSO bug.  
>>>
>>>Sender: BK latest (2.6.9-rc3) Tg3 (XX.YY.250.3)
>>>Receiver: BK + netdev(jeffm) + dave's latest e100 (XX.YY.1.73)
>>>
>>>Both machines are directly connected with a netgear 100mbit switch.
>>
> 
> IT ISN'T A NETWORK PROBLEM.  The problem is that iperf uses posix
> pthread mutex's to sychronize and it looks like a futex bug.

might not be a futex bug - check to see if iperf does
any writes, fflushes, etc, in a signal handler - i.e.
that its signal handling is thread-safe. glibc now
makes it a fatal bug..

thanks,
Nivedita
