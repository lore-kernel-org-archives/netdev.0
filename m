From: Sachin Sant <sachinp@in.ibm.com>
Subject: Re: [-next April 8] eHEA driver failure on powerpc
Date: Fri, 09 Apr 2010 23:18:18 +0530
Message-ID: <4BBF6862.3010600@in.ibm.com>
References: <20100408155113.ef8df30c.sfr@canb.auug.org.au> <4BBDC447.3040901@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	HERING2@de.ibm.com, Anton Blanchard <anton@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Linux/PPC Development <linuxppc-dev@ozlabs.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4BBDC447.3040901@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sachin Sant wrote:
> With today's next release, eHEA network interface on couple
> of power6 boxes fails to initialize.
>
> # modprobe ehea
> IBM eHEA ethernet device driver (Release EHEA_0102)
>  alloc irq_desc for 256 on node 0
>  alloc kstat_irqs on node 0
> irq: irq 590080 on host null mapped to virtual irq 256
> ehea: Error in ehea_plpar_hcall_norets: opcode=26c 
> ret=fffffffffffffffc arg1=8000000003000000 arg2=0 
> arg3=7000000000050400 arg4=fc9b0000 arg5=200 arg6=0 arg7=0
> ehea: Error in ehea_reg_mr_section: register_rpage_mr failed
> ehea: Error in ehea_reg_kernel_mr: registering mr failed
> ehea: Error in ehea_setup_ports: creating MR failed
> ehea 23c00200.lhea: setup_ports failed
> ehea: probe of 23c00200.lhea failed with error -5
I tracked this problem to the following commit.

commit 7545ba6f82924d4523f8f8a2baf2e517a750265d
powerpc/mm: Bump SECTION_SIZE_BITS from 16MB to 256MB

If i revert this commit, the network interface is initialized
properly. Verified this on two different power6 boxes.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------
