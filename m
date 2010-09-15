From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 15 Sep 2010 12:55:10 +0200
Message-ID: <4C90A60E.5040900@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de>	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>	<4C8E1918.5000007@pengutronix.de>	<003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>	<4C9078D3.50300@grandegger.com> <4C909518.5010309@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor@intel.com, socketcan-core@lists.berlios.de,
	qi.wang@intel.com, netdev@vger.kernel.org, gregkh@suse.de,
	yong.y.wang@intel.com, Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Morinaga <morinaga526@dsn.okisemi.com>, meego-dev@meego.com,
	arjan@linux.intel.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33760 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab0IOKyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 06:54:35 -0400
In-Reply-To: <4C909518.5010309@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 11:42 AM, Oliver Hartkopp wrote:
> On 15.09.2010 09:42, Wolfgang Grandegger wrote:
>> On 09/14/2010 02:46 AM, Masayuki Ohtake wrote:
>>> Hi Marc,
>>>
>>>>>> - implement NAPI
>>>>> Since Topcliff CAN HW register has only single rx buffer,
>>>>> I think NAPI is unnecessary.
>>>
>>>> Doesn't matter. Please try to implement it.
>>>
>>> Our CAN driver must pull received data from CAN-HW rx buffer as fast as it can
>>> so that the received data is not over-written by next received data.
>>> In case of implemented with NAPI,
>>> since NAPI has time-lagging after receiving first packet,
>>> probability of over-written(discarded) buffer is to be high.
>>> Thus, for our CAN HW, we should NOT implement with NAPI but normal "netif_rx".
>>
>> True, if you just use one RX-Object. But it just helps a little bit and
>> it would be much better to use the buffering on RX messages in the CAN
>> controller hardware, either by using more than one RX object, or
>> combining RX objects to a FIFO, or whatever your CAN controller supports.
> 
> Good point!
> 
> As long as the order of the received CAN frames is not shuffled (-> plain FIFO
> behaviour) using more than one RX buffer is a good idea.
> 
> Just a remark:
> 
> During the IDF the informations about the Topcliff Controller Hub have been
> reworked, so that some of the documentation became available for the public:
> 
> http://edc.intel.com/Platforms/Atom-E6xx/#hardware
> 
> Especially the Datasheet for the Platform Controller Hub EG20T can be found:
> 
> http://download.intel.com/embedded/chipsets/datasheet/324211.pdf
> 
> In chapter 13 there are some details about the CAN controller.

Ah, thanks for the link. The CAN controller seems then to be similar to
the OKI MSM9225B.

Wolfgang.

