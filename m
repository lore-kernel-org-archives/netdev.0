From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] ravb: Use common error handling code in ravb_probe()
Date: Sun, 29 Oct 2017 12:50:37 +0100
Message-ID: <3b700d27-2da5-b7d0-13f0-e55a7df4a24d@users.sourceforge.net>
References: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
 <CAMuHMdXEWpryexcrN7OYcsGfyE3Y_-7Ej2CfgvYgUbZFTTHEWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eugeniu Rosca <erosca@de.adit-jv.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yuval Shaia <yuval.shaia@oracle.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXEWpryexcrN7OYcsGfyE3Y_-7Ej2CfgvYgUbZFTTHEWg@mail.gmail.com>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> @@ -2069,10 +2069,9 @@ static int ravb_probe(struct platform_device *pdev)
>>                 irq = platform_get_irq_byname(pdev, "ch22");
>>         else
>>                 irq = platform_get_irq(pdev, 0);
>> -       if (irq < 0) {
>> -               error = irq;
>> -               goto out_release;
>> -       }
>> +       if (irq < 0)
>> +               goto failure_indication;
> 
> IMHO, it's really confusing that "irq" contains the error code, not "error".
> Especially when jumping to a meaningless label named "failure_indication"
> ("irq_failure" would be more intuitive).

Thanks for your constructive feedback.


> So I prefer the original code, regardless of the label name.

Can another attempt make sense to concentrate the setting of a variable
at the end of this function with more pleasing identifiers?

Regards,
Markus
