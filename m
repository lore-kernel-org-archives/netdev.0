From: Joe Eykholt <joe@nuovasystems.com>
Subject: Re: [Open-FCoE] [ANNOUNCE] Open-FCoE - Fibre Channel over Ethernet
 Project
Date: Wed, 28 Nov 2007 12:08:05 -0800
Message-ID: <474DCAA5.3020108@nuovasystems.com>
References: <10A7D0016239E24092DEF05CCC582E43028A636B@fmsmsx411.amr.corp.intel.com>	<20071128074426.GA30468@infradead.org> <474DAB30.20703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>, jeff@garzik.org,
	linux-scsi@vger.kernel.org, "Zou, Yi" <yi.zou@intel.com>,
	netdev@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	linux-kernel@vger.kernel.org,
	james.bottomley@hansenpartnership.com,
	"Ronciak, John" <john.ronciak@intel.com>, devel@open-fcoe.org,
	"Van De Ven, Arjan" <arjan.van.de.ven@intel.com>,
	davem@davemloft.net
To: Chris Leech <christopher.leech@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <474DAB30.20703@intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech wrote:
> Christoph Hellwig wrote:
>   
>> I just did a very quick glance over the tree.  Some extremly highlevel
>> comments to start with before actually starting the source review:
>>     
>
> Thanks for taking a look Christoph
>
>   
>>  - why do you need your own libcrc?  lib/crc32.c has a crc32_le
>>     
>
> We shouldn't, but we may want to add a CRC and copy routine.
>
>   
>>  - libsa should go.  Much of it is just wrappers of kernel functions
>>    that should be used directly.  Other like that hash, even or state
>>    helpers might either be opencoded in the caller or made completely
>>    generic in lib/.  Probably the former but we'll have to see.
>>     
>
> Yes, and along with it the last use of the BSD TAILQ macros.  Just 
> before Rob set up the open repos I finished converting most of those to 
> list_head, the only one left is in the sa_event mechanism.  Rather than 
> convert it I'd like to replace the use of sa_event with notifier call 
> chains.  I just need to finish auditing the use to make sure the 
> differences won't cause unexpected problems.
>
> After than and unwrapping kernel functions, I think the only thing left 
> before completly removing libsa is to open code the state machines.
>
> Similarly I think net_types.h need to go.
>
>   
Hi All,

[resending as plain text -sorry].

I've had a start at getting rid of sa_state, but I haven't tested it
yet.  It's a pretty straightforward change to just call the new state
routine directly instead of going through the table.  I'll submit that
in the next week or so, or if desired, someone else can take over the
work from the code I have.

           Joe
