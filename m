From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [2.6.19 PATCH 2/7] ehea: pHYP interface
Date: Mon, 21 Aug 2006 12:21:03 +0200
Message-ID: <44E9890F.2080708@de.ibm.com>
References: <200608181330.21507.ossthema@de.ibm.com>
	<20060818150600.GG5201@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060818150600.GG5201@martell.zuzino.mipt.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Fri, Aug 18, 2006 at 01:30:21PM +0200, Jan-Bernd Themann wrote:
>> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea_phyp.c
>> +++ kernel/drivers/net/ehea/ehea_phyp.c
> 
>> +	hret = ehea_h_register_rpage(hcp_adapter_handle, pagesize, queue_type,
>> +				     eq_handle, log_pageaddr, count);
>> +	return hret;
> 
> Just
> 	return ehea_h_register_rpage(...);
> 
>> +	hret = ehea_h_register_rpage(hcp_adapter_handle, pagesize, queue_type,
>> +				     cq_handle, log_pageaddr, count);
>> +	return hret;
> 
> Ditto.
> 
>> +	hret = ehea_h_register_rpage(hcp_adapter_handle, pagesize, queue_type,
>> +				     qp_handle, log_pageaddr, count);
>> +	return hret;
>> +}
> 
> Ditto.

Returncode handling was reworked throughout the whole driver. Those assignments
were modified according to your suggestion.

>> +static inline int hcp_epas_ctor(struct h_epas *epas, u64 paddr_kernel,
>> +				u64 paddr_user)
>> +{
>> +	epas->kernel.fw_handle = (u64) ioremap(paddr_kernel, PAGE_SIZE);
>> +	epas->user.fw_handle = paddr_user;
>> +	return 0;
>> +}
>> +
>> +static inline int hcp_epas_dtor(struct h_epas *epas)
>> +{
>> +
>> +	if (epas->kernel.fw_handle)
>> +		iounmap((void *)epas->kernel.fw_handle);
>> +	epas->user.fw_handle = epas->kernel.fw_handle = 0;
>> +	return 0;
>> +}
> 
> Always returns 0;

Correct. They're returning void now.

Thanks
Thomas
