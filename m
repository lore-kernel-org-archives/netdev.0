From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 5/8] S2io: module loadable parameters
Date: Thu, 14 Oct 2004 10:53:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E92E8.5020103@pobox.com>
References: <004e01c4b18b$4af2c090$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <004e01c4b18b$4af2c090$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Major objections to this patch.

Comments:

1) Should use new module_param() not older, less-type-strict 
MODULE_PARM() in 2.6.x kernels

2) don't create individual module options when arrays are far better 
suited to the task.  The following technique simply bloats up the code 
and makes use of loops impossible:

> +static unsigned int tx_fifo_len_0 = DEFAULT_FIFO_LEN;
> +static unsigned int tx_fifo_len_1;
> +static unsigned int tx_fifo_len_2;
> +static unsigned int tx_fifo_len_3;
> +static unsigned int tx_fifo_len_4;
> +static unsigned int tx_fifo_len_5;
> +static unsigned int tx_fifo_len_6;
> +static unsigned int tx_fifo_len_7;

3) do not enable NETIF_F_SG without also enabling a checksum-offload/TSO 
mode of some sort

>  
> -       dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
> +       dev->features |= NETIF_F_SG;
> +       if (cksum_offload_enable)
> +               dev->features |= NETIF_F_IP_CSUM;
>         if (sp->high_dma_flag == TRUE)
>                 dev->features |= NETIF_F_HIGHDMA;

4) I am unsure of the value of verify_load_parm().  Besides being huge, 
due to issue #2 (above), typically user module option limits should be 
documented, not necessarily tested.  Unix philosophy "root allowed to 
shoot themselves in the foot"
