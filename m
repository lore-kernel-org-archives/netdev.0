From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Thu, 16 Dec 2010 09:28:15 +0800
Message-ID: <AANLkTingt6SM+uasicwPSJRE5vYpvJ=GyFf3bbKhO72G@mail.gmail.com>
References: <cover.1292405004.git.fenghua.yu@intel.com> <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
 <1292446118.2603.11.camel@edumazet-laptop> <20101216011425.GA17446@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fenghua Yu <fenghua.yu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:61237 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab0LPB2h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 20:28:37 -0500
In-Reply-To: <20101216011425.GA17446@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 9:14 AM, Fenghua Yu <fenghua.yu@intel.com> wrot=
e:
>
> SKF_AD_QUEUE doesn't know number of rx queues. Thus user application =
can't
> specify right SKF_AD_QUEUE.

It is wrong. AFAIK, you can get the queue number through
/sys/class/net/eth*/queues/ or /proc/interrupts


>
> SKF_AD_QUEUE only works for rx. There is no queue bound interfaces fo=
r tx.

Do you really need queue number? The packets must be already spreaded
among CPUs, I think you means the current CPU number. Please see
SKF_AD_CPU added by Eric.

>
> I can change the patch set to use SKF_AD_QUEUE by removing the set rx=
 queue
> interface and still keep interfaces of
> #define SIOGNUMRXQUEUE 0x8939 =A0/* Get number of rx queues. */
> #define SIOGNUMTXQUEUE 0x893A =A0/* Get number of tx queues. */
> #define SIOSTXQUEUEMAPPING =A0 =A0 0x893C =A0/* Set tx queue mapping.=
 */
> #define SIOGRXQUEUEMAPPING =A0 =A0 0x893D =A0/* Get rx queue mapping.=
 */
> #define SIOGTXQUEUEMAPPING =A0 =A0 0x893E =A0/* Get tx queue mapping.=
 */
>
>>
>> Also your AF_PACKET patch only address mmaped sockets.
>>
> The new patch set will use SKF_AD_QUEUE for rx. So it won't be limite=
d to mmaped
> sockets.
>

If you turn to SKF_AD_QUEUE, I think no patch for kernel is needed.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
