From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [RFC] SNMP_ADD_STATS
Date: Wed, 12 Jun 2002 15:23:48 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020612182348.GP1073@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

	I've been cleaning up the network stacks and one thing that made me
have a use for the barf bags I have handy is this type of construct:

    ip_statistics[smp_processor_id()*2 + !in_softirq()].IpFragCreates += nfrags;

I've noticed that there is:

#define SNMP_INC_STATS(mib, field) ((mib)[2*smp_processor_id()+!in_softirq()].field++)

and

#define IP_INC_STATS(field) SNMP_INC_STATS(ip_statistics, field)

So I propose that we have

#define SNMP_ADD_STATS(mib, field, incr) ((mib)[2*smp_processor_id()+!in_softirq()].field += incr)

and

#define IP_ADD_STATS(field,incr) SNMP_ADD_STATS(ip_statistics, field, incr)

Any objections?

- Arnaldo
