From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] isdn: hisax: l3dss1.c:  Fix for possible null pointer
 dereference
Date: Tue, 20 May 2014 01:26:52 +0400
Message-ID: <537A771C.2050808@cogentembedded.com>
References: <1400534662-5729-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400534662-5729-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2014 01:24 AM, Rickard Strandqvist wrote:

> There is otherwise a risk of a possible null pointer dereference.

> Was largely found by using a static code analysis program called cppcheck.

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>   drivers/isdn/hisax/l3dss1.c |   11 ++++++-----
>   1 file changed, 6 insertions(+), 5 deletions(-)

> diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
> index cda7006..9ea7377 100644
> --- a/drivers/isdn/hisax/l3dss1.c
> +++ b/drivers/isdn/hisax/l3dss1.c
> @@ -2203,13 +2203,14 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
>   			memcpy(p, ic->parm.dss1_io.data, ic->parm.dss1_io.datalen); /* copy data */
>   			l = (p - temp) + ic->parm.dss1_io.datalen; /* total length */
>
> -			if (ic->parm.dss1_io.timeout > 0)
> -				if (!(pc = dss1_new_l3_process(st, -1)))
> -				{ free_invoke_id(st, id);
> +			if (ic->parm.dss1_io.timeout > 0) {
> +				if (!(pc = dss1_new_l3_process(st, -1))) {

    Assignments shouldn't be put into *if* statement. If you did run the patch 
thru scripts/checkpatch.pl, it would have told you.

> +					free_invoke_id(st, id);
>   					return (-2);

    Parens not needed. Could as well fix it here...

>   				}
> -			pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> -			pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +				pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> +				pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +			}

WBR, Sergei
