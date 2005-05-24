From: Paul Griffith <paulg@cs.yorku.ca>
Subject: Tuning GigE NFS / Re: tcp_mem setting bytes or memory pages
Date: Tue, 24 May 2005 13:38:03 -0400
Message-ID: <20050524133803.D11337@cs.yorku.ca>
References: <20050524125951.C11337@cs.yorku.ca> <200505241309.38771.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <200505241309.38771.jheffner@psc.edu>; from jheffner@psc.edu on Tue, May 24, 2005 at 01:09:38PM -0400
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 01:09:38PM -0400, John Heffner wrote:
> On Tuesday 24 May 2005 12:59 pm, Paul Griffith wrote:
> > Greetings,
> >
> > I have been searching the Internet for a final answer what the values
> > in net.ipv4.tcp_mem mean.
> >
> > I have seen some sites say it is in memory pages (4K blocks) and other
> > have said it is in KB. What the real answer?
> 
> It's in pages, as described in Documentation/networking/ip-sysctl.txt.  A lot 
> of people have this wrong.  If you find any incorrect sites, could you point 
> them out or send mail to their maintainers?  I've gotten a few corrected that 
> I've noticed so far.
> 
>   -John

Thanks for cleaning that up. I wanted to know, because I am tasked
with tunning a Linux NFS/SMB server on GigE. Details below:

Hardware:
P4/2.8Ghz/1GB/40GB HDD/G4 FX5200
Intel 865PERL

1) When I boot with v2.4.29 on my local computer tcp_mem set to the
   following:
cat /proc/sys/net/ipv4/tcp_mem
49152   65536   98304
(192MB)  (256MB)  (384MB)

2) When I boot the same computer with Knoppix v3.8.2 - v2.6.11.8 #3
cat /proc/sys/net/ipv4/tcp_mem
196608   262144  393216
(768MB)  (1024MB) (1536MB)

3) When I boot the same computer with Slax v5.0.5 - v2.6.11.8 #1
cat /proc/sys/net/ipv4/tcp_mem
98304   131073   196608
(384MB) (512MB)  (768MB)

I can understand the change in the tcp stack from 2.4.x to 2.6.x. What
I don't understand is why one level of the 2.6.11.8 #3 kernel will set
my max TCP_MEM to 1.5 * MEMORY and the other 2.6.11.8 #1 sets TCP_MEM
to .75 * MEMORY.

Anyone one has any idea what is going on here???

I am trying to understand the tcp stack in Linux because I have to
tune a GigE Linux based NFS/SMB server to as our departmental
fileserver. The server is currently using the default tcp settings on 2.4.26
[patched to support quotas on RiserFS].

Thanks
Paul
