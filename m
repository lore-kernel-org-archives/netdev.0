From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] isdn: hisax: l3dss1.c:  Fix for possible null pointer
 dereference
Date: Tue, 20 May 2014 01:24:28 +0400
Message-ID: <537A768C.8080807@cogentembedded.com>
References: <1400347101-25476-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400347101-25476-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/17/2014 09:18 PM, Rickard Strandqvist wrote:

> There is otherwise a risk of a possible null pointer dereference.

> Was largely found by using a static code analysis program called cppcheck.

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>   drivers/isdn/hisax/l3dss1.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)

> diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
> index cda7006..3ea6257 100644
> --- a/drivers/isdn/hisax/l3dss1.c
> +++ b/drivers/isdn/hisax/l3dss1.c
> @@ -2208,8 +2208,12 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
>   				{ free_invoke_id(st, id);
>   					return (-2);
>   				}
> -			pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> -			pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +
> +			if (pc)
> +			{

    { sould be on the same line as *if*.

> +				pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> +				pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +			}

WBR, Sergei
