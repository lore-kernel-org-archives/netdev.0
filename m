From: "Johannes Petersson" <johpe@vimmerbytidning.se>
Subject: r8169 and 2.4.26 finally working
Date: Fri, 14 May 2004 17:46:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c439ca$b0c39040$4500a8c0@freelancer>
Reply-To: <johpe@vimmerbytidning.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <romieu@fr.zoreil.com>, <a.nielsen@optushome.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

This is the story so far, how it finally worked out and a bit of a recap

for the netdev@oss.sgi.com list.

I run Slackware 9.1 on a server with a MSI motherboard that has a 
RealTek 8169 gigabit lan. When copying large files from the server it 
hangs / crashes and it is really slow when writing large files to the 
server. From reading on the net I found out that the original r8169 
driver (ver. 1.2) is not working properly.

I first compiled and installed the 2.4.26 kernel and hoped that it would

solve my problems which it didn't.

Then I was in contact with both Francois Romieu and Adam Nielsen since 
these guys had been writing a lot of very informative stuff on the 
subject at seclists.org and netdev@oss.sgi.com. I downloaded and tried 
their three different patches:
http://www.fr.zoreil.com/people/francois/misc/20040420-2.4.26-r8169.c-st
able.patch
http://www.fr.zoreil.com/people/francois/misc/20040504-2.4.27-pre1-r8169
.c-test.patch
http://seclists.org/lists/linux-kernel/2004/Apr/0627.html

The patches were tried one at a time to the vanilla sources for the 
2.4.26 kernel. The 2.4.26-r8169.c-stable.patch gave the usual error
about not beeing able to patch the file completely when I applied it to
the kernel source.

The patch from Adam didn't work for me either, it too, gave the usual
message about not beeing able to patch the file.

The only patched that actually applied without any problems to the 
kernel was the 20040504-2.4.27-pre1-r8169.c-test.patch from Francois. At

that time I had some hope. But while compiling the kernel with the 
2.4.27-pre1-r8169 patch I got the following compile errors when I issued
"make bzImage":
Implicit declaration of netdev_priv
(I continued anyway with make modules, and make modules_install). Make
modules_install gave me this error:
Depmod: unresolved symbols in /lib/modules/2.4.26/.../r8169.o
After rebooting this kernel, the rtl8169 driver of course didn't work. 

Then I thought that I would have to resort to compiling and installing 
the 2.6.6 kernel which is supposed to solve the problem according to 
Francois and Adam. But before I did this I gave the official driver 
(ver. 1.6) from RealTeks homepage a try:
http://www.realtek.com.tw/downloads/downloads1-3.aspx?software=True&comp
amodel=RTL8169S-32%2F64

I compiled and installed the driver and did modprobe and started doing 
some testing. As it turns out the system actually worked with this 
driver. I rebooted and since then the server has been up and running 
without problems. Maybe RealTeks 1.6 driver isn't the best, but it works

for me with kernel 2.4.26 and performs pretty well while copying files 
in the gigabit lan.

I hope this little novel of mine can help somebody else with the same 
problem and big thanks to Francois and Adam for helping me out.

Sincerely
Johannes Petersson
