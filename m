From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NAPI interrupt data
Date: Sat, 15 Feb 2003 13:55:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E4E8D32.6090706@pobox.com>
References: <3E4DE95C.2050804@pobox.com> <20030215092908.E16812@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030215092908.E16812@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Sat, 15 Feb 2003, Jeff Garzik wrote:
> 
> 
>>bash-2.05b$ ./x.pl data.crumb
>>135 samples, 21578 avg
>>bash-2.05b$ ./x.pl data.hum
>>130 samples, 11213 avg
>>
> 
> 
> Probably the first 5-10 samples as well as the last 5-10 amples to get
> more accuracy.
> 
> This data looks fine, no?

Over 4000 interrupts per second was not something I was hoping for, to 
be honest.  ttcp did not even report 50% CPU utilization, so I reach the 
conclusion that both machines can handle well in excess of 4,000 
interrupts per second...  but overall I do not like the unbounded nature 
of the interrupt rate.  This data makes me lean towards a software[NAPI] 
+ hardware mitigation solution, as opposed to totally depending on 
software interrupt mitigation.


 > definetly the scsi device is skewing things
> (you are writting data to disk for example).

Yes, though only once 5 seconds when ext3 flushes.  With nothing else 
going on but "ttcp" and "cat /proc/interrupts >> data ; sleep 1" there 
should be very little disk I/O.  I agree it is skewing by an unknown 
factor, however.


> - The 500Kpps from ttcp doesnt sound right; tcp will slow you down.
> perhaps use ttcp to send udp packets to get a more interesting view.


No, I ran 500,000 buffer I/Os total from ttcp ("-n 500000").  That 
doesn't really say anything about packets per second.  The only thing I 
measured was interrupts per second.  It was my mistake to type "packets" 
in the first email :/

	Jeff
