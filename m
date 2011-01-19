From: Janek Wrobel <wrr@google.com>
Subject: Altering default SO_PRIORITY of a socket.
Date: Wed, 19 Jan 2011 11:02:52 +0100
Message-ID: <AANLkTi=X3_fW9cB2nj6W=E9kivU_NfdbhGGh0Fvxbn4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:24364 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688Ab1ASKCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 05:02:55 -0500
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p0JA2tIS008014
	for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:02:55 -0800
Received: from fxm12 (fxm12.prod.google.com [10.184.13.12])
	by kpbe17.cbf.corp.google.com with ESMTP id p0JA2qsb028121
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:02:53 -0800
Received: by fxm12 with SMTP id 12so650299fxm.0
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:02:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Does Linux allow to change default priority of listening or connected
sockets, without process ever calling setsockopt(..,SO_PRIORITY,..)?
In other words, in a following sequence of events, is it possible that
priority_a, or priority_b will ever be non 0 (assuming all calls
succeeded)?

sock = socket(AF_INET, SOCK_STREAM, 0);
bind(sock, some address)
listen(sock, ...)
int priority_a;
getsockopt(sock, SOL_SOCKET, SO_PRIORITY, &priority_a, sizeof(priority_a))

client_sock = accept(sock, ...);
int priority_b;
getsockopt(client_sock, SOL_SOCKET, SO_PRIORITY, &priority_b,
sizeof(priority_b))

thanks,
Janek
