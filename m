From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH] net: ethtool support to configure number of channels
Date: Fri, 1 Apr 2011 22:47:01 -0700
Message-ID: <BEEA5B09-0726-463D-B542-234C4FB49FC5@qlogic.com>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
 <1301677824.4679.10.camel@bwh-desktop>
 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
 <1301712946.10056.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:20627 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751318Ab1DBFsM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 01:48:12 -0400
In-Reply-To: <1301712946.10056.179.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 1, 2011, at 7:55 PM, Ben Hutchings wrote:

> On Fri, 2011-04-01 at 21:36 -0500, Amit Salecha wrote:
>>> I'm not sure why you reduced this to a single count.  If if the driver
>>> or hardware doesn't allow certain combinations of counts, it might be
>>> necessary to configure several types at the same time
>>>
>>>> +/* Channel ID is made up of a type */
>>>> +enum ethtool_channel_id {
>>>> +   ETH_CHAN_TYPE_RX = 0x1,
>>>> +   ETH_CHAN_TYPE_TX = 0x2
>>>> +};
>>> [...]
>>>
>>> enum ethtool_channel_id was meant to be an identifier of a specific
>>> channel.  An enumeration of channel types should be named differently.
>>>
>>
>> I will name it as ethtool_channel_type. Any other suggestion ?
>>
>>> This also omits the 'combined' and 'other' types.  Most multiqueue
>>> drivers pair up RX and TX queues so that most channels combine RX and
>>> TX
>>> work.
>>
>> 'combined' is ok, what is use of 'other' ?
>
> Could be link interrupts, SR-IOV coordination, or something else.  Not
> something you'd likely be able to change, but it could be useful to know
> that some interrupts are allocated to them.  Actually, that does mean it
> might be helpful for the 'get' operation to return a minimum value along
> with the maximum value.

Are you thinking of using the 'other' field as a way to a represent a 'virtual port'
that a VF could have. A virtual port could have a set of rx/tx rings, interrupts,
QoS parameters, MAC filters, VLAN ids etc. etc. A VF could have one or many such
channels. If thats the case, I would think that configuring these channels should
be done via a PF rather than on a VF. It is possible I could get you totally wrong here,
however it would be good to hear your thoughts.

-Anirban

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

