From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next]tc: B.W limits can now be specified in
 %
Date: Tue, 31 Oct 2017 17:35:52 +0100
Message-ID: <20171031173552.33aadc14@shemminger-XPS-13-9360>
References: <20171028172657.GA5039@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, doucette@bu.edu, michel.machado@gmail.com
To: Nishanth Devarajan <ndev2021@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:44585 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753824AbdJaQgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:36:18 -0400
Received: by mail-lf0-f68.google.com with SMTP id 75so19780129lfx.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:36:17 -0700 (PDT)
In-Reply-To: <20171028172657.GA5039@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Oct 2017 22:57:00 +0530
Nishanth Devarajan <ndev2021@gmail.com> wrote:

>  
> +int read_prop(char *dev, char *prop, long *value)
> +{
> +	char fname[41], buf[80], *endp;
> +	ssize_t len;
> +	int fd;
> +	long result;
> +
> +	sprintf(fname, "/sys/class/net/%s/%s", dev, prop);
> +	fd = open(fname, O_RDONLY);
> +	if (fd < 0) {
> +		if (strcmp(prop, "tun_flags"))
> +			fprintf(stderr, "open %s: %s\n", fname,
> +				strerror(errno));
> +		return -1;
> +	}
> +	len = read(fd, buf, sizeof(buf)-1);
> +	close(fd);
> +	if (len < 0) {
> +		fprintf(stderr, "read %s: %s", fname, strerror(errno));
> +		return -1;
> +	}
> +
> +	buf[len] = 0;
> +	result = strtol(buf, &endp, 0);
> +	if (*endp != '\n') {
> +		fprintf(stderr, "Failed to parse %s\n", fname);
> +		return -1;
> +	}
> +	*value = result;
> +	return 0;
> +}

I know you copy and pasted this code, but it was already a mess.
 1. It should use stdio (fopen/fgets)
 2. It should not be looking for signed values (ie use strtoul)
 3. It should not be special casing "tun_flags"
 4. It needs to check for all possible parsing errors, with strtoul.
    (hint read strtoul man page for how errors are reported).
