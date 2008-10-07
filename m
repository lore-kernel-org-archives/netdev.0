From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 09:16:13 -0500
Message-ID: <48EB6F2D.100@linux-foundation.org>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755278AbYJGOTy@vger.kernel.org>
In-Reply-To: <20081007083750.GB17079@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Oct 06, 2008 at 06:08:09PM -0500, Corey Minyard (minyard@acm.org) wrote:
>> Would using SLAB_DESTROY_BY_RCU be ok, or would that be too expensive?
> 
> I tested skb destruction via RCU path, and got 2.5 times worse numbers
> with small-packets-bulk-transfer workload.

Was this with regular RCU freeing? This will cool down the cacheline before
frees. You need SLAB_DESTROY_BY_RCU to keep the objects cache hot.
