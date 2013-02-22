From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] tipc: byte-based overload control on socket receive queue
Date: Fri, 22 Feb 2013 11:54:29 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7164@saturn3.aculab.com>
References: <20130219142629.GA31871@hmsreliant.think-freely.org> <5123BC46.40909@ericsson.com> <20130219191833.GB31871@hmsreliant.think-freely.org> <5123DDA8.5090202@ericsson.com> <20130219214439.GC31871@hmsreliant.think-freely.org> <5125F5D3.1000509@ericsson.com> <20130221150746.GA2730@shamino.rdu.redhat.com> <51265134.5080001@ericsson.com> <20130221181656.GC2730@shamino.rdu.redhat.com> <51268C21.8050602@donjonn.com> <20130221213528.GA32764@hmsreliant.think-freely.org> <5127541C.9070306@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jon Maloy" <maloy@donjonn.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Ying Xue" <ying.xue@windriver.com>
To: "Jon Maloy" <jon.maloy@ericsson.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44662 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756432Ab3BVLz6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 06:55:58 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01315-08 for <netdev@vger.kernel.org>;
 Fri, 22 Feb 2013 11:55:52 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <5127541C.9070306@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> grab net lock (read mode)
>    <do some packet sanity check>
>    grab node lock
> -->   grab port lock
>         grab socket lock
>            <check sk_rcvbuf>
>         release socket lock
> -->   release port lock
>       <perform link level protocol check>
>     release node lock
> release net lock
> grab port lock
>   grab socket lock
>      <check sk_rcvbuf>
>      <deliver or reject>
>   release socket lock
> release port lock

You probably don't need to grab the socket lock itself, you
only need to be able to read a 'receive buffer full' marker.
That could (probably) be done with some careful coding in the
socket create/delete paths.

Another option is to remember that the socket became full
the previous time, and only do the early check of the
receive buffer state when it had previously been full.

	David
