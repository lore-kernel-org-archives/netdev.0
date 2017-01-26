From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net 1/5] ibmvnic: harden interrupt handler
Date: Thu, 26 Jan 2017 13:05:40 -0600
Message-ID: <b6646479-b370-b19b-48e2-27e20f67a31a@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170126102802.4f920418@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com, linuxppc-dev@lists.ozlabs.org,
 nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20170126102802.4f920418@xeon-e3>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On 01/26/2017 12:28 PM, Stephen Hemminger wrote:
> On Wed, 25 Jan 2017 15:02:19 -0600
> Thomas Falcon <tlfalcon@linux.vnet.ibm.com> wrote:
>
>>  static irqreturn_t ibmvnic_interrupt(int irq, void *instance)
>>  {
>>  	struct ibmvnic_adapter *adapter = instance;
>> +	unsigned long flags;
>> +
>> +	spin_lock_irqsave(&adapter->crq.lock, flags);
>> +	vio_disable_interrupts(adapter->vdev);
>> +	tasklet_schedule(&adapter->tasklet);
>> +	spin_unlock_irqrestore(&adapter->crq.lock, flags);
>> +	return IRQ_HANDLED;
>> +}
>> +
> Why not use NAPI? rather than a tasklet
>
This interrupt function doesn't process packets, but message passing between firmware and driver for determining device capabilities and available resources, such as the number TX and RX queues. 
