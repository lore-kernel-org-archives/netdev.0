From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Optimize loopback stats
Date: Tue, 15 Mar 2005 16:09:43 -0800
Message-ID: <42377947.5090207@us.ibm.com>
References: <200503151819_MC3-1-98A4-43AC@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>,
        linux-netdev <netdev@oss.sgi.com>
To: Chuck Ebbert <76306.1226@compuserve.com>
In-Reply-To: <200503151819_MC3-1-98A4-43AC@compuserve.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:

> On 15-Mar-05 Nivedita Singhvi wrote:
> 
> 
>>Chuck Ebbert wrote:
>>
>>
>>>  This patch optimizes the loopback driver's statistics by using a single
>>>counter for rx and tx stats instead of one for rx and one for tx.  It also
>>>adds unlikely() to the test for TSO since it's no longer supported by default.
>>>(Maybe the TSO code should be bracketed by "#if 0" ?)
>>
>>Hmm, some of us want those counters separate - if this is really
>>needed, could it be a configurable option, please?
> 
> 
>  But they _are_ separately reported -- get_stats() takes care of that.
> Everything looks exactly the same to userspace after this patch.
> 
> 
> 
> 
> --
> Chuck
> 
Hmm, I see the following in your patch:

+               stats->rx_bytes   += lb_stats->rx_tx_bytes;
+               stats->tx_bytes    = stats->rx_bytes;

Doesn't that mean RX is now twice what it should be
and so is TX? They are separately reported, but if
so, their real value should be half of rx_tx_bytes
each, correct?

thanks,
Nivedita
