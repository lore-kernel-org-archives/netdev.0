From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 3/9] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Wed, 14 Sep 2016 23:37:45 +0300
Message-ID: <c0aac71d-2033-f210-5494-15399b477e37@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-4-grygorii.strashko@ti.com>
 <20160914135214.GA28592@localhost.localdomain>
 <606f7cfc-aa34-528b-df04-7a60a9695425@ti.com> <20160914203217.GD12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914203217.GD12195@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 11:32 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 11:10:48PM +0300, Grygorii Strashko wrote:
>> On 09/14/2016 04:52 PM, Richard Cochran wrote:
>>> On Wed, Sep 14, 2016 at 04:02:25PM +0300, Grygorii Strashko wrote:
> 
>>>> -	if (!cpts->rx_enable)
>>>> +	if (!cpts || !cpts->rx_enable)
>>>>  		return;
> 
>> Ok. I can't say I'd like all this checks, but there are internal requirement 
>> to allow CPTS to be disabled though DT on KS2 (even if built in).
>> I'd try to clarify and return back here.
>>
>> But It'll be good to know your position - acceptable/can be discussed/completely unacceptable?
> 
> Look at that code snippet.  We already test for @cpts->rx_enable.  If
> you want to disable cpts at run time, just avoid setting that field.
> There is no need for any new tests or return codes.
> 

The problem is that if cpts not initialized than pinter on 
cpts (in consumer/parent driver - NETCP) will be NULL.
So, rx_enable will be unaccessible and cause crash :(

-- 
regards,
-grygorii
