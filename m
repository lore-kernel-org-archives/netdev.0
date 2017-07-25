From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netns: more input validation
Date: Tue, 25 Jul 2017 13:47:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD003FE88@AcuExch.aculab.com>
References: <20170725133031.7735-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: 'Matteo Croce' <mcroce@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:64783 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbdGYNr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 09:47:28 -0400
In-Reply-To: <20170725133031.7735-1-mcroce@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce
> Sent: 25 July 2017 14:31
> ip netns accepts invalid input as namespace name like an empty string or a
> string longer than the maximum file name length.
> Check that the netns name is not empty and less than or equal to NAME_MAX.
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>
> ---
>  ip/ipnetns.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index 42549944..198e9de8 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -768,7 +768,8 @@ static int netns_monitor(int argc, char **argv)
> 
>  static int invalid_name(const char *name)
>  {
> -	return strchr(name, '/') || !strcmp(name, ".") || !strcmp(name, "..");
> +	return !*name || strlen(name) > NAME_MAX ||
> +		strchr(name, '/') || !strcmp(name, ".") || !strcmp(name, "..");

Think I'd check:
	!name[0] || !memchr(name, 0, NAME_MAX) || strchr(name, '/') ||
		(name[0] == '.' && (!name[1] || (name[1] == '.' && !name[2])))

	David
