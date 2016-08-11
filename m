From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Thu, 11 Aug 2016 13:46:55 +0200
Message-ID: <0ab4653f-81b5-565c-2fca-b52b425ecf43@hartkopp.net>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
 <20160808140546.GA1733@awelinux>
 <808e919b-8643-2113-9fde-001861883abe@grandegger.com>
 <20160809061038.GC1733@awelinux>
 <a0169f54-c8c7-5cf6-b93b-acd4a308a052@hartkopp.net>
 <20160811071458.GA25813@awelinux>
 <1d81436b-4ad2-a34f-e2e1-accde0b16a47@hartkopp.net>
 <20160811085826.GB25813@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>, mkl@pengutronix.de,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	jthumshirn@suse.de, andy@wernerandy.de, michael.miehling@men.de
To: Andreas Werner <andreas.werner@men.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:26524 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbcHKLrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 07:47:18 -0400
In-Reply-To: <20160811085826.GB25813@awelinux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/11/2016 10:58 AM, Andreas Werner wrote:
> On Thu, Aug 11, 2016 at 10:45:00AM +0200, Oliver Hartkopp wrote:


>> When you still have the possibility to change the IP core I would suggest to
>> create some kind of 16/32 bit value which you can pass to the CAN controller
>> along with the CAN frame to be sent.
>>
>> And when this frame comes back due to the loopback you can use this non-zero
>> 16/32 bit value to match into a list of tx skb pointers for IFF_ECHO.
>>
>> E.g. when this 16/32 bit value is zero this CAN frame obviously was received
>> from another CAN node.
>>
>> Just an idea.
>>
>
> I am not sure if we have a way to change the IP but i will try to talk with
> my IC designer. He will be available next week.
>
> Your idea sounds good. I will check a few more driver to get more information
> how they did the implementation.
>

I just looked into your patch at 
http://marc.info/?l=linux-can&m=146952497113100&w=2

The

	struct men_z192_cf_buf {
		u32 can_id;
		u32 data[2];
		u32 length;
	};

has a u32 for the length which is masked by

	#define MEN_Z192_CFBUF_LEN	GENMASK(3, 0)

in men_z192_read_frame() and is just copied in men_z192_xmit()

	writel(cf->can_dlc, &cf_buf->length);

as only 4 bits are used in the u32 length you probably already can use 
the upper 16 bits for the discussed IFF_ECHO purpose.

Don't know how your IP core handles this u32 length when you enable the 
loopback - maybe the upper 16 bits are still there in the receive path 
and you can implement this idea directly :-)

Regards,
Oliver
