From: "w.szukalski" <szukw000@students.uni-mainz.de>
Subject: linux-2.4.21 and IPv6
Date: Sun, 17 Aug 2003 02:09:25 GMT
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817020925.A875@keun>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have written a small program to test IPv6 multicasting
with linux-2.4.21. A LAN connects three linux boxes. 

I have found, that IPv6 sometimes fails.


With IPv6 group 'ff02::1':

    struct sockaddr_in6 read6, write6;
    struct ipv6_mreq mreq6;

	inet_pton(AF_INET6, group, &mreq6.ipv6mr_multiaddr);

	read6.sin6_family = AF_INET6;
	read6.sin6_port = htons(readport);
	read6.sin6_flowinfo = 0;
	read6.sin6_scope_id = 0;

//	ALTERNATIVE 1:
	memset(&read6.sin6_addr, 0, sizeof(struct in6_addr));

//	ALTERNATIVE 2:
	inet_pton(AF_INET6, host, &read6.sin6_addr);

//	ALTERNATIVE 3:	
	read6.sin6_addr = mreq6.ipv6mr_multiaddr;
	
    bind(reader, (struct sockaddr *)&read6, sizeof(read6) );

bind() fails for alternative 3 with 'Invalid argument'.

    connect(writer, (struct sockaddr*)&write6,
      sizeof(struct sockaddr_in6));

connect() always fails with 'Invalid argument'.

With IPv4 group '224.0.0.1':

    struct sockaddr_in read4, write4;
    struct ip_mreq mreq4;

	inet_pton(AF_INET, group, &mreq4.imr_multiaddr);

	read4.sin_family = AF_INET;
	read4.sin_port = htons(readport);


//	ALTERNATIVE 1:
	read4.sin_addr.s_addr = 0;

//	ALTERNATIVE 2:
    inet_pton(AF_INET, host, &read4.sin_addr);

//	ALTERNATIVE 3:
	read4.sin_addr = mreq4.imr_multiaddr;
	
    bind(reader, (struct sockaddr *)&read4, sizeof(read4) );

bind() never fails.

    connect(writer, (struct sockaddr*)&write4,
	  sizeof(struct sockaddr_in));

connect() never fails.


Why does IPv6 sometimes fail?


winfried
