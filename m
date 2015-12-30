From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: Re: [PATCH 1/1] include/uapi/linux/sockios.h: mark SIOCRTMSG unused
Date: Wed, 30 Dec 2015 12:14:39 +0100
Message-ID: <5683BC9F.7060603@gmx.de>
References: <1451427722-2672-1-git-send-email-xypron.glpk@gmx.de>
 <5683B863.9010506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63533 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019AbbL3LPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 06:15:03 -0500
In-Reply-To: <5683B863.9010506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2015 11:56 AM, Michael Kerrisk (man-pages) wrote:
> Hi Heinrich,
> 
> On 12/29/2015 11:22 PM, Heinrich Schuchardt wrote:
>> IOCTL SIOCRTMSG does nothing but return EINVAL.
>>
>> So comment it as unused.
> 
> Can you say something about how you confirmed this?
> It's not immediately obvious from the code.
> 
> Cheers,
> 
> Michael

grep -GHrn SIOCRTMSG

SIOCRTMSG is only used in:
* net/ipv4/af_inet.c
* include/uapi/linux/sockios.h

inet_ioctl calls ip_rt_ioctl.

ip_rt_ioctl only handles SIOCADDRT and SIOCDELRT and returns -EINVAL
otherwise.

cf.
http://lkml.iu.edu/hypermail/linux/kernel/0911.0/02636.html

Best regards

Heinrich

> 
> 
>> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
>> ---
>>  include/uapi/linux/sockios.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
>> index e888b1a..8e7890b 100644
>> --- a/include/uapi/linux/sockios.h
>> +++ b/include/uapi/linux/sockios.h
>> @@ -27,7 +27,7 @@
>>  /* Routing table calls. */
>>  #define SIOCADDRT	0x890B		/* add routing table entry	*/
>>  #define SIOCDELRT	0x890C		/* delete routing table entry	*/
>> -#define SIOCRTMSG	0x890D		/* call to routing system	*/
>> +#define SIOCRTMSG	0x890D		/* unused			*/
>>  
>>  /* Socket configuration controls. */
>>  #define SIOCGIFNAME	0x8910		/* get iface name		*/
>>
> 
> 
