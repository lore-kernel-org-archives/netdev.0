From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/5] ibmvnic: harden interrupt handler
Date: Thu, 26 Jan 2017 10:28:02 -0800
Message-ID: <20170126102802.4f920418@xeon-e3>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com, jallen@linux.vnet.ibm.com,
 linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
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

On Wed, 25 Jan 2017 15:02:19 -0600
Thomas Falcon <tlfalcon@linux.vnet.ibm.com> wrote:

>  static irqreturn_t ibmvnic_interrupt(int irq, void *instance)
>  {
>  	struct ibmvnic_adapter *adapter = instance;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&adapter->crq.lock, flags);
> +	vio_disable_interrupts(adapter->vdev);
> +	tasklet_schedule(&adapter->tasklet);
> +	spin_unlock_irqrestore(&adapter->crq.lock, flags);
> +	return IRQ_HANDLED;
> +}
> +

Why not use NAPI? rather than a tasklet
