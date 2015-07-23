From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: stp: when using userspace stp stop
 kernel hello and hold timers
Date: Thu, 23 Jul 2015 19:05:56 +0200
Message-ID: <55B11EF4.8050501@cumulusnetworks.com>
References: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150723095945.2b4dd59e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150723095945.2b4dd59e@urahara>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 07/23/2015 06:59 PM, Stephen Hemminger wrote:
> On Thu, 23 Jul 2015 09:07:37 -0700
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> +		/* Stop hello and hold timer */
>> +		spin_lock_bh(&br->lock);
>> +		del_timer(&br->hello_timer);
>> +		list_for_each_entry(p, &br->port_list, list)
>> +			del_timer(&p->hold_timer);
>> +		spin_unlock_bh(&br->lock);
> 
> Wouldn't it be easier to use del_timer_sync here?
> 
I think it should work. Also I have an error in the commit message
about the kernel BPDU sending which I need to correct. I'll prepare
a v2 with your suggestion and fixed commit message.

Thanks,
 Nik
