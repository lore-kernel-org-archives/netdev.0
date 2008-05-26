From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency,
 transactions, parallels.
Date: Sun, 25 May 2008 21:41:19 -0400
Message-ID: <483A153F.7000907@garzik.org>
References: <20080525134055.GA30630@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080525134055.GA30630@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote on the blog page:
> Probably there will be some kind of a status messages for servers (i.e.
> going offline, do not send me data, or I'm becoming slow, do not read
> from me and so on). 

Often you can capture this information in a more scalable manner, by 
having the clients measure an observable _output_ such as latency, over 
time.

Each transaction gives the client new feedback about the server(s) being 
offline (i.e. timeout), becoming slow, etc.


Another potential tool is having the server(s) send an abstract number, 
from 0-100, indicating their level of desire for new { read | write } 
transactions.  Let us call this client hint "weight".  Rather than have 
a bunch of status messages that indicate server load average, or 
do-not-read state, summarize this information into read_weight and 
write_weight hints to the client.

With just a few (two?) simple variables, the client is given the ability 
to automatically balance and scale load across the cluster, work around 
failing servers, etc.

Write balancing need not be overly complex...

	Jeff


