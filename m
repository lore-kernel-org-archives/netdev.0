From: Jeff Garzik <jeff@garzik.org>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 16:20:14 -0400
Message-ID: <470BE27E.4000101@garzik.org>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>	<20071009.042441.30182968.davem@davemloft.net>	<470B77A9.600@garzik.org>
	<20071009.131438.74562715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.131438.74562715.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 09 Oct 2007 08:44:25 -0400
> 
>> David Miller wrote:
>>> From: Krishna Kumar2 <krkumar2@in.ibm.com>
>>> Date: Tue, 9 Oct 2007 16:51:14 +0530
>>>
>>>> David Miller <davem@davemloft.net> wrote on 10/09/2007 04:32:55 PM:
>>>>
>>>>> Ignore LLTX, it sucks, it was a big mistake, and we will get rid of
>>>>> it.
>>>> Great, this will make life easy. Any idea how long that would take?
>>>> It seems simple enough to do.
>>> I'd say we can probably try to get rid of it in 2.6.25, this is
>>> assuming we get driver authors to cooperate and do the conversions
>>> or alternatively some other motivated person.
>>>
>>> I can just threaten to do them all and that should get the driver
>>> maintainers going :-)
>> What, like this?  :)
> 
> Thanks, but it's probably going to need some corrections and/or
> an audit.

I would be happy if someone wanted to audit that patch.


> If you unconditionally take those locks in the transmit function,
> there is probably an ABBA deadlock elsewhere in the driver now, most
> likely in the TX reclaim processing, and you therefore need to handle
> that too.

And I most certainly checked the relevant transmit paths and other 
locking to make sure lock ordering was correct.

	Jeff
