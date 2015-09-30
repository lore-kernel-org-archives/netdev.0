From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH wpan-tools 2/2] security: add store and restore scripts
Date: Wed, 30 Sep 2015 16:09:04 +0200
Message-ID: <560BED00.8020909@osg.samsung.com>
References: <1443425134-27910-1-git-send-email-alex.aring@gmail.com>
 <1443425134-27910-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de
To: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:40111 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbbI3OJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:09:09 -0400
In-Reply-To: <1443425134-27910-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28/09/15 09:25, Alexander Aring wrote:
> This patch adds two new bash script commands."iwpan-store" and
> "iwpan-restore" which can store and restore the current security
> table settings. This is currently a very KISS solution, we should lookup
> iptables implementation for storing and restoring the tables.
>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>   src/Makefile.am   |  4 ++++
>   src/iwpan-restore | 36 ++++++++++++++++++++++++++++++++++++
>   src/iwpan-store   | 39 +++++++++++++++++++++++++++++++++++++++

Why not call it ipwan-dump and iwpan-restore? You use dump in other 
places and I think it makes a lot sense to keep this.
>   3 files changed, 79 insertions(+)
>   create mode 100755 src/iwpan-restore
>   create mode 100755 src/iwpan-store
>
> diff --git a/src/Makefile.am b/src/Makefile.am
> index b2177a2..37a6d82 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -1,6 +1,10 @@
>   bin_PROGRAMS = \
>   	iwpan
>   
> +bin_SCRIPTS = \
> +	iwpan-store \
> +	iwpan-restore
> +
>   iwpan_SOURCES = \
>   	iwpan.c \
>   	iwpan.h \
> diff --git a/src/iwpan-restore b/src/iwpan-restore
> new file mode 100755
> index 0000000..0e305f6
> --- /dev/null
> +++ b/src/iwpan-restore
> @@ -0,0 +1,36 @@
> +#!/bin/bash
> +
> +WPAN_DEV=""
> +FILE=""
> +
> +function usage() {
> +	echo "usage: -d \$WPAN_DEV -f \$FILE"
> +}
> +
> +while getopts "d:f:" opt; do
> +	case $opt in
> +		d)
> +			WPAN_DEV=$OPTARG
> +			;;
> +		f)
> +			FILE=$OPTARG
> +			;;
> +		?)
> +			usage
> +			;;
> +	esac
> +done
> +
> +if [ -z $FILE ] || [ -z $WPAN_DEV ]
> +then
> +	usage
> +	exit 1
> +fi
> +
> +function failed() {
> +	echo "failed" >&2
> +}
> +
> +export WPAN_DEV &&
> +/bin/bash $FILE ||
> +failed
> diff --git a/src/iwpan-store b/src/iwpan-store
> new file mode 100755
> index 0000000..acce807
> --- /dev/null
> +++ b/src/iwpan-store
> @@ -0,0 +1,39 @@
> +#!/bin/bash
> +
> +WPAN_DEV=""
> +FILE=""
> +
> +function usage() {
> +	echo "usage: -d \$WPAN_DEV -f \$FILE"
> +}
> +
> +while getopts "d:f:" opt; do
> +	case $opt in
> +		d)
> +			WPAN_DEV=$OPTARG
> +			;;
> +		f)
> +			FILE=$OPTARG
> +			;;
> +		?)
> +			usage
> +			;;
> +	esac
> +done
> +
> +if [ -z $FILE ] || [ -z $WPAN_DEV ]
> +then
> +	usage
> +	exit 1
> +fi
> +
> +function failed() {
> +	echo "failed" >&2
> +	rm $FILE
> +}
> +
> +iwpan dev $WPAN_DEV seclevel dump > $FILE &&
> +iwpan dev $WPAN_DEV device dump >> $FILE &&
> +iwpan dev $WPAN_DEV devkey dump >> $FILE &&
> +iwpan dev $WPAN_DEV key dump >> $FILE ||
> +failed

regards
Stefan Schmidt
