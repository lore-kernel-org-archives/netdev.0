From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 20:39:38 +0100
Message-ID: <41C335FA.2050009@dbservice.com>
References: <41C26DD1.7070006@trash.net> <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com> <41C330F7.4000806@dbservice.com> <200412172030.04831.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-os@analogic.com, Bill Davidsen <davidsen@tmr.com>,
        James Morris <jmorris@redhat.com>, Patrick McHardy <kaber@trash.net>,
        Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Oliver Neukum <oliver@neukum.org>
In-Reply-To: <200412172030.04831.oliver@neukum.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
>>But the difference between you example (cp /dev/zero /dev/mem) and 
>>passing unchecked data to the kernel is... you _can_ check the data and 
> 
> 
> This is the difference:
> static int open_port(struct inode * inode, struct file * filp)
> {
> 	return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
> }
> (from mem.c)
> 

OK, but my point was, whenever you can check the 'contents' of the data 
passed to the kernel, do it. You can't check if the data someone writes 
to /dev/mem is valid or not, but you can check for out-of-range/etc. 
data in ioctl & friends.

tom
