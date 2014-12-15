From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Sun, 14 Dec 2014 17:56:41 -0800
Message-ID: <1418608606-1569264-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45599 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750767AbaLOB5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 20:57:14 -0500
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBF1tpxn008598
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:13 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1r9caw9n5u-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 17:57:10 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 ac9f579a83fd11e4896224be05956610-8efd8390 for <netdev@vger.kernel.org>;	Sun,
 14 Dec 2014 17:57:07 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have been using the kernel ftrace infra to collect TCP per-flow statistics.
The following patch set is a first slim-down version of our
existing implementation. We would like to get some early feedback
and make it useful for others.

[RFC PATCH net-next 1/5] tcp: Add TCP TRACE_EVENTs:
Defines some basic tracepoints (by TRACE_EVENT).

[RFC PATCH net-next 2/5] tcp: A perf script for TCP tracepoints:
A sample perf script with simple ip/port filtering and summary output.

[RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for tcp tracer:
Declares a few more tracepoints (by DECLARE_TRACE) which are
used by the tcp_tracer.  The tcp_tracer is in the patch 5/5.

[RFC PATCH net-next 4/5] tcp: Introduce tcp_sk_trace and related structs:
Defines a few tcp_trace structs which are used to collect statistics
on each tcp_sock.

[RFC PATCH net-next 5/5] tcp: Add TCP tracer:
It introduces a tcp_tracer which hooks onto the tracepoints defined in the
patch 1/5 and 3/5.  It collects data defined in patch 4/5. We currently
use this tracer to collect per-flow statistics.  The commit log has
some more details.

Thanks,
--Martin
