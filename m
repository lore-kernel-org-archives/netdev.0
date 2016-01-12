From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 13/53] perf tools: Prevent calling machine__delete() on
 non-allocated machine
Date: Tue, 12 Jan 2016 15:03:39 +0800
Message-ID: <5694A54B.3090209@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-14-git-send-email-wangnan0@huawei.com> <20160111154202.GE18367@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:56094 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbcALHGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 02:06:25 -0500
In-Reply-To: <20160111154202.GE18367@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/1/11 23:42, Arnaldo Carvalho de Melo wrote:
> Em Mon, Jan 11, 2016 at 01:48:04PM +0000, Wang Nan escreveu:
>> To prevent futher commits calling machine__delete() on non-allocated
>> 'struct machine' (which would cause memory corruption), this patch
>> enforces machine__init(), record whether a machine structure is
>> dynamically allocated or not, and warn if machine__delete() is called
>> on incorrect object.
> Not sure on this one, I think I voiced this before, this seems like
> something to be tested using some static analysis tool or even checking
> if the address for the struct hitting machine__delete() is from malloc
> or not.
>
> I.e. if we do it here, we may have to do it to any other struct where we
> allocate it in the stack or via malloc, and furthermore there are cases
> where we embed a struct in another, when we would free just the main
> struct but not the second, embedded one, that would need just calling
> foo__exit() and not foo__delete().
>
> - Arnaldo
>   
OK. Let's drop this one.

Thank you.
