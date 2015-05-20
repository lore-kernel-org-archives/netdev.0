From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 06/10] pktgen: new pktgen helper functions for
 samples scripts
Date: Wed, 20 May 2015 14:23:17 -0700
Message-ID: <CAHA+R7NzKMLLZ954F+moZ7wFEFWPTBzo0Js9rGnU02kkPTPB0A@mail.gmail.com>
References: <20150519213326.9070.18264.stgit@ivy>
	<20150519213608.9070.31995.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34078 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725AbbETVXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 17:23:18 -0400
Received: by wicmc15 with SMTP id mc15so379153wic.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 14:23:17 -0700 (PDT)
In-Reply-To: <20150519213608.9070.31995.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 2:36 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> +
> +# More generic replacement for pgset(), that does not depend on global
> +# variable for proc file.
> +function proc_cmd() {
> +    local result
> +    local proc_file=$1
> +    # after shift, the remaining args are contained in $@
> +    shift
> +    local proc_ctrl=${PROC_DIR}/$proc_file
> +    if [[ ! -e "$proc_ctrl" ]]; then
> +       err 3 "proc file:$proc_ctrl does not exists (dev added to thread?)"
> +    else
> +       if [[ ! -w "$proc_ctrl" ]]; then
> +           err 4 "proc file:$proc_ctrl not writable, not root?!"
> +       fi
> +    fi
> +
> +    if [[ "$DEBUG" == "yes" ]]; then
> +       echo "cmd: $@ > $proc_ctrl"
> +    fi
> +    # Quoting of "$@" is important for space expansion
> +    echo "$@" > "$proc_ctrl"
> +    local status=$?
> +
> +    result=`cat $proc_ctrl | fgrep "Result: OK:"`

Nit: useless usage of cat, grep/fgrep accepts a file name.


> +    if [[ "$result" == "" ]]; then

You can test $?

> +       cat $proc_ctrl | fgrep Result: >&2
> +    fi
> +    if (( $status != 0 )); then
> +       err 5 "Write error($status) occured cmd: \"$@ > $proc_ctrl\""

Typo: occurred


> +    fi
> +}
> +
