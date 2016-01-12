From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 9/9] samples/bpf: test percpu array map
Date: Tue, 12 Jan 2016 15:44:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC461F@AcuExch.aculab.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
 <1452527821-12276-10-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Martin KaFai Lau" <kafai@fb.com>
To: 'Ming Lei' <tom.leiming@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-10-git-send-email-tom.leiming@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ming Lei
> Sent: 11 January 2016 15:57
...
> ---
>  samples/bpf/test_maps.c | 110 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 110 insertions(+)
> 
> diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
> index 6299ee9..ff5d373 100644
> --- a/samples/bpf/test_maps.c
> +++ b/samples/bpf/test_maps.c
> @@ -142,6 +142,106 @@ static void test_arraymap_sanity(int i, void *data)
>  	close(map_fd);
>  }
> 
> +static int handle_one_cpu(unsigned cpu, void *val_cpu, void *val)
> +{
> +	unsigned long *cnt = val;
> +
> +	*cnt += *(long *)val_cpu;

Integer pointer casts ring big alarm bells - they are accidents
waiting to happen.

If the pointers are 'pointer to long' then define them as such.

	David
