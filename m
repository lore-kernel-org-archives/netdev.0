From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH v4 net-next 5/8] sunvnet: straighten up message event
 handling logic
Date: Mon, 13 Feb 2017 11:18:12 -0800
Message-ID: <073f1737-3990-1a69-fc31-ed86c8fd64bd@oracle.com>
References: <1487012224-403399-1-git-send-email-shannon.nelson@oracle.com>
 <1487012224-403399-6-git-send-email-shannon.nelson@oracle.com>
 <1487012802.6214.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1487012802.6214.3.camel@perches.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/13/2017 11:06 AM, Joe Perches wrote:
> On Mon, 2017-02-13 at 10:57 -0800, Shannon Nelson wrote:
>> The use of gotos for handling the incoming events made this code
>> harder to read and support than it should be.  This patch straightens
>> out and clears up the logic.
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
>> ---
>>  drivers/net/ethernet/sun/sunvnet_common.c |   94 ++++++++++++++---------------
>>  1 files changed, 45 insertions(+), 49 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
> []
>> @@ -738,41 +738,37 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
> []
>> +	/* we don't expect any other bits */
>> +	BUG_ON(port->rx_event & ~(LDC_EVENT_DATA_READY |
>> +				  LDC_EVENT_RESET |
>> +				  LDC_EVENT_UP));
>
> Is it really necessary to use BUG_ON here?
>

I'm carrying this from the original code because we want to know asap if 
we have a low level protocol issue.  It should never happen in the 
field, but we want to notice it as soon as we can when doing development 
and testing.  In this patch I've simply made it more obvious and up 
front that we're doing this test rather than having it buried in the 
logic a few lines further down.

sln
