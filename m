From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] remove lots of IS_ERR_VALUE abuses
Date: Fri, 27 May 2016 23:04:58 +0100
Message-ID: <20160527220458.GV14480@ZenIV.linux.org.uk>
References: <1464384685-347275-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrzej Hajda <a.hajda@samsung.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	David Airlie <airlied@linux.ie>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Adrian Hunter <adrian.hunter@intel.com>,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	Russell King <linux@armlinux.org.uk>,
	Bob Peterson <rpeterso@redhat.com>, linux-acpi@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464384685-347275-1-git-send-email-arnd@arndb.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2016 at 11:23:25PM +0200, Arnd Bergmann wrote:

> @@ -837,7 +837,7 @@ static int load_flat_shared_library(int id, struct lib_info *libs)
>  
>  	res = prepare_binprm(&bprm);
>  
> -	if (!IS_ERR_VALUE(res))
> +	if (res >= 0)

	if (res == 0), please - prepare_binprm() returns 0 or -E...

> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -521,7 +521,7 @@ static int p9_check_errors(struct p9_client *c, struct p9_req_t *req)
>  		if (p9_is_proto_dotu(c))
>  			err = -ecode;
>  
> -		if (!err || !IS_ERR_VALUE(err)) {
> +		if (!err || !IS_ERR_VALUE((unsigned long)err)) {

Not really - it's actually
		if (p9_is_proto_dotu(c) && ecode < 512)
			err = -ecode;

		if (!err) {
			...
> @@ -608,7 +608,7 @@ static int p9_check_zc_errors(struct p9_client *c, struct p9_req_t *req,
>  		if (p9_is_proto_dotu(c))
>  			err = -ecode;
>  
> -		if (!err || !IS_ERR_VALUE(err)) {
> +		if (!err || !IS_ERR_VALUE((unsigned long)err)) {

Ditto.
