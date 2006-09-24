From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: bcm43xx driver unstable behaviour (and linux wireless is junk btw)
Date: Sun, 24 Sep 2006 12:43:18 +1000
Message-ID: <1159065798.5924.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi folks !

So this is 2.6.18 + Larry "fix" (though I've seen this problem before,
it seems using WPA just make it happen more often).

This is also a 4318, so the link is pretty weak due to the Tx Power
problem and I suspects it makes the driver problems more visible...

So basically, I "lose" the link every few minutes for a minute or so, I
suspect it's related to wpa_supplicant vs. the ack losses due to the
4318 Tx Power problems. That alone would be ok though, if the driver
wasn't totally stuck after a while. (Similar problem to after
sleep/wakeup, looks like nothign goes through).

When it goes bunk, it looks like that in the logs:

Sep 24 12:24:18 localhost kernel: [  285.686826] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
Sep 24 12:24:18 localhost kernel: [  285.686976] SoftMAC: generic IE set to <....>
Sep 24 12:24:18 localhost kernel: [  285.686999] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
Sep 24 12:24:28 localhost kernel: [  295.687229] SoftMAC: Start scanning with channel: 1
Sep 24 12:24:28 localhost kernel: [  295.687240] SoftMAC: Scanning 14 channels
Sep 24 12:24:29 localhost kernel: [  296.027053] SoftMAC: Scanning finished
Sep 24 12:24:29 localhost kernel: [  296.035267] SoftMAC: generic IE set to <....>
Sep 24 12:24:29 localhost kernel: [  296.035310] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
Sep 24 12:24:31 localhost kernel: [  297.690969] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
Sep 24 12:24:39 localhost kernel: [  306.039210] SoftMAC: Start scanning with channel: 1
Sep 24 12:24:39 localhost kernel: [  306.039222] SoftMAC: Scanning 14 channels
Sep 24 12:24:39 localhost kernel: [  306.375046] SoftMAC: Scanning finished
Sep 24 12:24:39 localhost kernel: [  306.383018] SoftMAC: generic IE set to <....>
Sep 24 12:24:39 localhost kernel: [  306.383075] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
Sep 24 12:24:42 localhost kernel: [  309.695021] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
Sep 24 12:24:49 localhost kernel: [  316.387211] SoftMAC: Start scanning with channel: 1

 etc...

Then, if you rmmod, you get back a prompt, and about a second later, the kernel blows up. At this point,
I've always been in X and it's too dead to dump anything into the disk logs so I don't know what
the precise crash is, but it looks to me like the driver is not properly removing some timer
or something there.

Note that it also goes "bunk" on sleep/wakeup, and sometimes ifdown/ifup... in general, it's fragile and
just 'loses it' in which case the only way to get it back is to rmmod/insmod.

Doesn't help me to have my prism54 not working with WPA (apparently, the driver looks like it handles hostap
ioctls but it doesn't agree on the ioctl numbers, among others, with whatever wpa_supplicant sends when
configured to wpa mode... somebody knows if that driver is maintained ?)

So at this point I have a choice between two wireless devices that don't work (and none of them is less than
a couple years old). Looks like the linux wireless situation isn't getting any better since last KS.

Oh and I don't care about "it works in dscape stack" sort of crap I regulary get. I want something that
works with upstream kernels. That isn't that much to ask... or is it ?

Ben, back to ethernet cables.
