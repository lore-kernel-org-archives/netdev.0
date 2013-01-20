From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Mon, 21 Jan 2013 00:48:46 +0900
Message-ID: <50FC11DE.6000707@linux-ipv6.org>
References: <50FBA02C.9030203@linux-ipv6.org> <20130120105058.1aee26c4@stein>
	<50FBC8D5.50205@linux-ipv6.org> <50FC0353.8090902@gmail.com>
	<50FC08E5.6020903@linux-ipv6.org> <50FC0A6C.205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <50FC0A6C.205@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Stephan Gatzka wrote:
> 
>> "Off-link source" means the source exists on the different L2
>> network.  In other words, source is connected via router(s).
>>
>>           ethernet             firewire
>>   Host -------------- Router ------------ Host
>>
> 
> O.k., understood. But the receiving router verifies the checksum of incoming packets and sends them on the firewire link. On firewire we have CRC checksums to ensure the integrity of packets.
> 
> I agree with your patch but I don't see why we should check them in the driver. I thought your patch will ensure that the checksums will be verified in the upper layers.

Routers do not inspect whole packet.
For IPv4, we have IP checksum, but routers (usually) do not check
upper-layer (e.g. UDP) checksum.
For IPv6, we do not have IP checksum.

CHECKSUM_UNNECESSARY means the driver has verified upper layer
(e.g. TCP/UDP) checksum.  Modern hardware can perform upper-layer
checksumming as well. But of course, not all drivers are required
to verify the upper-layer checksum; if the driver do not verify
checksum in the packet, just say CHECKSUM_NONE.

Regards,

--yoshfuji

------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. ON SALE this month only -- learn more at:
http://p.sf.net/sfu/learnmore_123012
