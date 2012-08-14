From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net PATCH v1 2/2] net: netprio: fd passed in SCM_RIGHTS datagram
 not set correctly
Date: Mon, 13 Aug 2012 20:00:25 -0700
Message-ID: <5029BF49.6090202@intel.com>
References: <20120814013939.3144.13167.stgit@jf-dev1-dcblab> <20120814013944.3144.53854.stgit@jf-dev1-dcblab> <20120814023128.GG23464@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814023128.GG23464@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/13/2012 7:31 PM, Al Viro wrote:
> On Mon, Aug 13, 2012 at 06:39:45PM -0700, John Fastabend wrote:
>>   		/* Bump the usage count and install the file. */
>>   		get_file(fp[i]);
>>   		fd_install(new_fd, fp[i]);
>> +		sock = sock_from_file(fp[i], &err);
>> +		if (sock)
>> +			sock->sk->sk_cgrp_prioidx = prioidx;
>
> Better to do that before fd_install() exposes the sucker; it's not
> a serious issue, but it's more obviously correct that way.
>

Right. Moved it in v2.
