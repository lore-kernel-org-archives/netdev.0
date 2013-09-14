From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ptp: measure the time offset between PHC and system clock
Date: Sat, 14 Sep 2013 23:21:50 +0400
Message-ID: <5234B74E.5000402@cogentembedded.com>
References: <20130914080306.GC23682@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130914080306.GC23682@zhudong.nay.redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/14/2013 12:03 PM, Dong Zhu wrote:

> This patch add a method into testptp.c to measure the time offset
> between phc and system clock through the ioctl PTP_SYS_OFFSET.

> Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
> ---
>   Documentation/ptp/testptp.c | 40 ++++++++++++++++++++++++++++++++++++++--
>   1 file changed, 38 insertions(+), 2 deletions(-)

> diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
> index f59ded0..72bb030 100644
> --- a/Documentation/ptp/testptp.c
> +++ b/Documentation/ptp/testptp.c
[...]
> @@ -376,6 +387,31 @@ int main(int argc, char *argv[])
>   		}
>   	}
>
> +	if (offset) {
> +		sysoff = calloc(1, sizeof(*sysoff));
> +		if (!sysoff) {
> +			perror("calloc");
> +			return -1;
> +		}
> +		sysoff->n_samples = n_samples;
> +
> +		if (ioctl(fd, PTP_SYS_OFFSET, sysoff))
> +			perror("PTP_SYS_OFFSET");
> +		else
> +			puts("time offset between PHC and
> +					 system clock request okay");

    Don't break the string constant that way, there'll be all spaces between 
"and" and "system" included in it. Do it like this:

			puts("time offset between PHC and "
			     "system clock request okay");

WBR, Sergei

