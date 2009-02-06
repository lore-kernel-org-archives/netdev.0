From: Ben Greear <greearb@candelatech.com>
Subject: Re: Regression on VIA C3 motherboard, commit: 66f2173e2
Date: Fri, 06 Feb 2009 11:52:58 -0800
Message-ID: <498C951A.3070101@candelatech.com>
References: <498A93E5.2080509@candelatech.com> <alpine.LFD.2.00.0902061350470.26256@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: Len Brown <lenb@kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0902061350470.26256@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Len Brown wrote:
> Thanks for the bisect, Ben.
> 
> Please test the patch below.

With this patch, performance is fine, and I do not see
my smp hack being exercised.  I still have ACPI off
in the BIOS, and on in the kernel (ie, no change
from the original test case).

So, this very well could be the fix.

Thanks,
Ben

> diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> index 775c97a..a885295 100644
> --- a/drivers/acpi/tables.c
> +++ b/drivers/acpi/tables.c
> @@ -293,7 +293,12 @@ static void __init check_multiple_madt(void)
>  
>  int __init acpi_table_init(void)
>  {
> -	acpi_initialize_tables(initial_tables, ACPI_MAX_TABLES, 0);
> +	acpi_status status;
> +
> +	status = acpi_initialize_tables(initial_tables, ACPI_MAX_TABLES, 0);
> +	if (ACPI_FAILURE(status))
> +		return 1;
> +
>  	check_multiple_madt();
>  	return 0;
>  }


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

