From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] usbnet/cdc_ncm: Don't use stack variables for DMA
Date: Fri, 12 Aug 2011 08:11:45 -0700 (PDT)
Message-ID: <20110812.081145.1237768611581199187.davem@davemloft.net>
References: <20110808123406.GA2526@zod.bos.redhat.com>
	<20110812150715.GD3014@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, alexey.orishko@stericsson.com, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jwboyer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812150715.GD3014@zod.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@redhat.com>
Date: Fri, 12 Aug 2011 11:07:16 -0400

> On Mon, Aug 08, 2011 at 08:34:06AM -0400, Josh Boyer wrote:
>> The cdc_ncm driver still has a few places where stack variables are
>> passed to the cdc_ncm_do_request function.  This triggers a stack trace in
>> lib/dma-debug.c if the CONFIG_DEBUG_DMA_API option is set.
>> 
>> Adjust these calls to pass parameters that have been allocated with
>> kzalloc.
>> 
>> Signed-off-by: Josh Boyer <jwboyer@redhat.com>
>> ---
>> v4: Rebase against 3.1-rc1
>> v3: Fix checkpatch errors
>> v2: Fix leak in error path
>> 
>>  drivers/net/usb/cdc_ncm.c |   47 ++++++++++++++++++++++++++++++++++++--------
>>  1 files changed, 38 insertions(+), 9 deletions(-)
> 
> Just curious, but which tree would this be pulled into?  usb or net or?

Probably net.
