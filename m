From: greg chesson <greg@atheros.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Thu, 09 Sep 2004 10:06:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41408D8A.5010307@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409082251.45771.vkondra@mail.ru> <413F70F0.6020709@atheros.com> <200409090815.40358.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca, jgarzik@pobox.com,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409090815.40358.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

good discussion.  some complementary thoughts below.

Vladimir Kondratiev wrote:
> gc>
> gc> Linux does the same thing (driver is configured by application code)
> gc>   although there does not yet exist a single app
> gc> that can serve as a common point of control for multiple vendor drivers.
> gc> I believe that achieving that goal is the real payoff for wireless Linux
> gc> users.
> 
> I would not fully agree here: for timing reasons, you can do scanning/AP 
> selection in user space, but for rate scaling, if we ever can do it generic, 
> you better be in kernel.
Existing APIs have a command to tell the driver to scan and return the 
result.
There are sometimes parameters to limit the scan to a certain amount of time
or certain channels or to sort the scan results on some metric, e.g. is-WPA.
The user-space app then selects an AP and commands the driver to associate.
That's all fine and well-understood.

An exception to this arrangement is background scanning where the driver
is expected to go off-channel and search around for other APs while 
remaining
associated with one AP.   The driver goes into power-save state with the 
current
AP while doing the scan.  There's enough of a real-time component to this,
that it needs to be implemented in the driver.   An extreme example is 
the work
being done for voip over 802.11.   Every vendor as well as the 802.11 
TGe and TGr
groups are pursuing techniques whereby the wireless subsystem goes into
power-save between voip codec samples (usually at 20ms intervals) except 
for those
times when it is doing off-channel background scanning (also between 
codec samples!).
This is an interesting implementation challenge.... and it's also 
necessary since it is
the only way to get cell-phone equivalent battery life for 802.11 devices
while also running at 802.11 power and phy rates.    The phone people in 
TGr also
have a goal of implementing fast handoff of an active voip call between APs
within 20ms.   The heavy problem with that is moving the security context
in a low-overhead manner without opening up new security holes.
I can see the possibility of enabling fast handoff via application

> From architecture point of view, MLME should be stack, not user app. For me, 
> management packets generation is same kind of activity as arp. 
I agree with this and tried to say it in previous emails....
> 
<snip>

> gc> Yes, for logic it is sufficient.
> gc> My personal approach would be to test the theory by examining
> gc> what fits or doesn't fit into David's API if I were to port one of the
> gc> MLME implementations that I work with.   Discover if it fits or not.
> 
> Sounds promising. Don't forget to share you findings.

roger.
