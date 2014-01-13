From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending
 refcount
Date: Mon, 13 Jan 2014 11:58:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D459065@AcuExch.aculab.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
 <1389543768-20234-4-git-send-email-dborkman@redhat.com>
 <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
 <52D3CBA5.4080301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <dborkman@redhat.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52878 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751101AbaAMMAe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 07:00:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06957-06 for <netdev@vger.kernel.org>;
 Mon, 13 Jan 2014 12:00:27 +0000 (GMT)
In-Reply-To: <52D3CBA5.4080301@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
...
> But I think I found a different problem with this idea. It could
> happen with net devices as well, but probably less likely as there
> might be a better distribution of hold/puts among CPUs. However,
> for TX_RING, if we pin the process to a particular CPU, and since
> the destructor is invoked through ksoftirqd, we could end up with
> a misbalance and if the process runs long enough eventually
> overflow for one particular CPU. We could work around that, but I
> think it's not worth the effort.

The sum will be 'correct' when summed across all the cpu even if
one of the values has wrapped - provided all the arithmetic is
unsigned and the variables all the same type.

	David
